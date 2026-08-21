from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Float
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    fullname = Column(String, nullable=True)
    avatar_url = Column(String, default="https://api.dicebear.com/7.x/bottts/svg?seed=user")
    
    # Game Economy
    coins = Column(Integer, default=500)
    energy = Column(Integer, default=10)
    max_energy = Column(Integer, default=10)
    last_energy_refill = Column(DateTime, default=datetime.utcnow)
    
    # Progress & Rating
    xp = Column(Integer, default=0)
    level = Column(Integer, default=1)
    rating_score = Column(Integer, default=1000) # MMR / Trophy
    total_wins = Column(Integer, default=0)
    total_matches = Column(Integer, default=0)
    
    # VIP status
    is_vip = Column(Boolean, default=False)
    vip_expires_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    icon = Column(String, default="help_outline")
    color = Column(String, default="#4F46E5")

    questions = relationship("Question", back_populates="category")


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"))
    question_text = Column(Text, nullable=False)
    option_a = Column(String, nullable=False)
    option_b = Column(String, nullable=False)
    option_c = Column(String, nullable=False)
    option_d = Column(String, nullable=False)
    correct_option = Column(String, nullable=False) # 'A', 'B', 'C', 'D'
    explanation = Column(Text, nullable=True)
    difficulty = Column(String, default="medium") # easy, medium, hard

    category = relationship("Category", back_populates="questions")


class MatchHistory(Base):
    __tablename__ = "matches"

    id = Column(Integer, primary_key=True, index=True)
    player1_id = Column(Integer, ForeignKey("users.id"))
    player2_id = Column(Integer, ForeignKey("users.id"))
    player1_score = Column(Integer, default=0)
    player2_score = Column(Integer, default=0)
    winner_id = Column(Integer, nullable=True)
    coins_won = Column(Integer, default=50)
    created_at = Column(DateTime, default=datetime.utcnow)


class ShopItem(Base):
    __tablename__ = "shop_items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    item_type = Column(String, nullable=False) # 'COINS', 'ENERGY', 'BOOSTER_5050', 'BOOSTER_TIME', 'VIP_PASS'
    price_uzs = Column(Integer, default=0)
    coin_price = Column(Integer, default=0)
    value = Column(Integer, default=1) # Quantity or days
    icon = Column(String, default="shopping_bag")
    is_popular = Column(Boolean, default=False)
