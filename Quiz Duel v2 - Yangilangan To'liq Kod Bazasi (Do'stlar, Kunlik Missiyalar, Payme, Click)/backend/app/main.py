from fastapi import FastAPI, Depends, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta

from .database import Base, engine, get_db
from .models import User, Category, Question, ShopItem, MatchHistory
from .websocket_manager import manager
from .seed import seed_data

app = FastAPI(title="Quiz Duel API & Game Engine", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    seed_data()

# --- Schemas ---
class LoginRequest(BaseModel):
    username: str

class PurchaseRequest(BaseModel):
    user_id: int
    item_id: int
    payment_method: str # 'COINS', 'GOOGLE_PLAY', 'CLICK', 'PAYME'

# --- Endpoints ---

@app.get("/")
def read_root():
    return {"message": "Quiz Duel Game Server Online", "version": "1.0.0"}

@app.post("/api/auth/login")
def login_or_register(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == req.username).first()
    if not user:
        user = User(
            username=req.username,
            fullname=req.username.capitalize(),
            coins=500,
            energy=10,
            rating_score=1000
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    return user

@app.get("/api/users/{user_id}")
def get_user_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")
    return user

@app.get("/api/categories")
def get_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()

@app.get("/api/leaderboard")
def get_leaderboard(db: Session = Depends(get_db)):
    top_users = db.query(User).order_by(User.rating_score.desc()).limit(50).all()
    result = []
    for idx, u in enumerate(top_users):
        result.append({
            "rank": idx + 1,
            "id": u.id,
            "username": u.username,
            "fullname": u.fullname,
            "avatar_url": u.avatar_url,
            "rating_score": u.rating_score,
            "level": u.level,
            "is_vip": u.is_vip,
            "weekly_prize": "1 000 000 UZS" if idx == 0 else ("500 000 UZS" if idx == 1 else ("250 000 UZS" if idx == 2 else "VIP Pass")) if idx < 10 else None
        })
    return result

@app.get("/api/shop/items")
def get_shop_items(db: Session = Depends(get_db)):
    return db.query(ShopItem).all()

@app.post("/api/shop/purchase")
def purchase_item(req: PurchaseRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == req.user_id).first()
    item = db.query(ShopItem).filter(ShopItem.id == req.item_id).first()

    if not user or not item:
        raise HTTPException(status_code=404, detail="Foydalanuvchi yoki mahsulot topilmadi")

    # If paying with in-game coins
    if req.payment_method == "COINS":
        if item.coin_price <= 0:
            raise HTTPException(status_code=400, detail="Ushbu mahsulot faqat haqiqiy pulga sotiladi")
        if user.coins < item.coin_price:
            raise HTTPException(status_code=400, detail="Tangalar yetarli emas")
        user.coins -= item.coin_price

    # Apply Item
    if item.item_type == "COINS":
        user.coins += item.value
    elif item.item_type == "ENERGY":
        user.energy = min(user.max_energy, user.energy + item.value)
    elif item.item_type == "VIP_PASS":
        user.is_vip = True
        user.vip_expires_at = datetime.utcnow() + timedelta(days=item.value)
        user.max_energy = 20
        user.energy = 20

    db.commit()
    db.refresh(user)

    return {
        "success": True,
        "message": f"{item.title} muvaffaqiyatli faollashtirildi!",
        "updated_user": user
    }

# --- WebSocket Game Endpoint ---
@app.websocket("/ws/duel/{user_id}")
async def websocket_duel_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.handle_message(user_id, data)
    except WebSocketDisconnect:
        manager.disconnect(user_id)
