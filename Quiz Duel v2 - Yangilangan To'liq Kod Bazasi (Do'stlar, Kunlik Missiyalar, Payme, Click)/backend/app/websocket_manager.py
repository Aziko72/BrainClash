import asyncio
import json
import random
from typing import Dict, List, Optional
from fastapi import WebSocket
from sqlalchemy.orm import Session
from .database import SessionLocal
from .models import User, Question, MatchHistory

class GameRoom:
    def __init__(self, room_id: str, p1_id: int, p1_ws: WebSocket, p2_id: int, p2_ws: WebSocket):
        self.room_id = room_id
        self.p1_id = p1_id
        self.p1_ws = p1_ws
        self.p2_id = p2_id
        self.p2_ws = p2_ws
        
        self.p1_score = 0
        self.p2_score = 0
        self.current_round = 0
        self.total_rounds = 5
        self.questions: List[Question] = []
        self.p1_answered = False
        self.p2_answered = False
        self.p1_answer_data = None
        self.p2_answer_data = None
        self.is_active = True

    async def send_to_both(self, data: dict):
        msg = json.dumps(data)
        try:
            await self.p1_ws.send_text(msg)
        except Exception:
            pass
        try:
            await self.p2_ws.send_text(msg)
        except Exception:
            pass

    async def start_game(self):
        db: Session = SessionLocal()
        all_q = db.query(Question).all()
        if len(all_q) >= self.total_rounds:
            self.questions = random.sample(all_q, self.total_rounds)
        else:
            self.questions = all_q

        u1 = db.query(User).filter(User.id == self.p1_id).first()
        u2 = db.query(User).filter(User.id == self.p2_id).first()

        # Deduct 1 energy for duel
        if u1 and u1.energy > 0:
            u1.energy -= 1
        if u2 and u2.energy > 0:
            u2.energy -= 1
        db.commit()

        # 1. Match Found Event
        await self.p1_ws.send_text(json.dumps({
            "event": "match_found",
            "room_id": self.room_id,
            "opponent": {
                "id": u2.id if u2 else 0,
                "username": u2.username if u2 else "Raqib",
                "avatar_url": u2.avatar_url if u2 else "",
                "rating_score": u2.rating_score if u2 else 1000,
                "level": u2.level if u2 else 1,
            },
            "total_rounds": self.total_rounds
        }))

        await self.p2_ws.send_text(json.dumps({
            "event": "match_found",
            "room_id": self.room_id,
            "opponent": {
                "id": u1.id if u1 else 0,
                "username": u1.username if u1 else "Raqib",
                "avatar_url": u1.avatar_url if u1 else "",
                "rating_score": u1.rating_score if u1 else 1000,
                "level": u1.level if u1 else 1,
            },
            "total_rounds": self.total_rounds
        }))

        db.close()
        await asyncio.sleep(2.5) # Wait for vs animation

        # Run Game Loop
        for i in range(self.total_rounds):
            if not self.is_active:
                break
            self.current_round = i + 1
            await self.run_round(self.questions[i])

        if self.is_active:
            await self.finish_game()

    async def run_round(self, q: Question):
        self.p1_answered = False
        self.p2_answered = False
        self.p1_answer_data = None
        self.p2_answer_data = None

        # Send round start (omit correct_option)
        await self.send_to_both({
            "event": "round_start",
            "round_index": self.current_round,
            "total_rounds": self.total_rounds,
            "time_limit": 10,
            "question": {
                "id": q.id,
                "text": q.question_text,
                "option_a": q.option_a,
                "option_b": q.option_b,
                "option_c": q.option_c,
                "option_d": q.option_d,
            }
        })

        # Wait up to 10 seconds or until both answer
        for _ in range(20): # 20 * 0.5s = 10s
            if (self.p1_answered and self.p2_answered) or not self.is_active:
                break
            await asyncio.sleep(0.5)

        # Calculate scores for this round
        p1_correct = False
        p2_correct = False
        p1_gained = 0
        p2_gained = 0

        if self.p1_answer_data:
            if self.p1_answer_data.get("selected_option") == q.correct_option:
                p1_correct = True
                tl = float(self.p1_answer_data.get("time_left", 0))
                p1_gained = 100 + int(max(0, tl) * 10)
                self.p1_score += p1_gained

        if self.p2_answer_data:
            if self.p2_answer_data.get("selected_option") == q.correct_option:
                p2_correct = True
                tl = float(self.p2_answer_data.get("time_left", 0))
                p2_gained = 100 + int(max(0, tl) * 10)
                self.p2_score += p2_gained

        # Send Round Result
        await self.send_to_both({
            "event": "round_result",
            "round_index": self.current_round,
            "correct_option": q.correct_option,
            "explanation": q.explanation,
            "p1_id": self.p1_id,
            "p1_correct": p1_correct,
            "p1_gained": p1_gained,
            "p1_total_score": self.p1_score,
            "p2_id": self.p2_id,
            "p2_correct": p2_correct,
            "p2_gained": p2_gained,
            "p2_total_score": self.p2_score,
        })

        await asyncio.sleep(2.5) # Time to see answer review

    def record_answer(self, user_id: int, data: dict):
        if user_id == self.p1_id:
            self.p1_answered = True
            self.p1_answer_data = data
        elif user_id == self.p2_id:
            self.p2_answered = True
            self.p2_answer_data = data

    async def finish_game(self):
        db: Session = SessionLocal()
        u1 = db.query(User).filter(User.id == self.p1_id).first()
        u2 = db.query(User).filter(User.id == self.p2_id).first()

        winner_id = None
        coins_reward = 50
        xp_reward = 100

        if self.p1_score > self.p2_score:
            winner_id = self.p1_id
        elif self.p2_score > self.p1_score:
            winner_id = self.p2_id

        # Update stats
        if u1:
            u1.total_matches += 1
            if winner_id == self.p1_id:
                u1.total_wins += 1
                u1.coins += coins_reward * (2 if u1.is_vip else 1)
                u1.xp += xp_reward
                u1.rating_score += 25
            elif winner_id == self.p2_id:
                u1.rating_score = max(0, u1.rating_score - 15)
                u1.xp += 25
            else: # Draw
                u1.coins += 20
                u1.xp += 40

        if u2:
            u2.total_matches += 1
            if winner_id == self.p2_id:
                u2.total_wins += 1
                u2.coins += coins_reward * (2 if u2.is_vip else 1)
                u2.xp += xp_reward
                u2.rating_score += 25
            elif winner_id == self.p1_id:
                u2.rating_score = max(0, u2.rating_score - 15)
                u2.xp += 25
            else: # Draw
                u2.coins += 20
                u2.xp += 40

        # Save match
        match = MatchHistory(
            player1_id=self.p1_id,
            player2_id=self.p2_id,
            player1_score=self.p1_score,
            player2_score=self.p2_score,
            winner_id=winner_id,
            coins_won=coins_reward
        )
        db.add(match)
        db.commit()
        db.close()

        await self.send_to_both({
            "event": "game_over",
            "winner_id": winner_id,
            "p1_id": self.p1_id,
            "p1_score": self.p1_score,
            "p2_id": self.p2_id,
            "p2_score": self.p2_score,
            "coins_won": coins_reward,
            "xp_won": xp_reward
        })


class WebSocketManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}
        self.waiting_queue: List[int] = []
        self.rooms: Dict[str, GameRoom] = {}
        self.user_rooms: Dict[int, str] = {}

    async def connect(self, user_id: int, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
        if user_id in self.waiting_queue:
            self.waiting_queue.remove(user_id)
        if user_id in self.user_rooms:
            room_id = self.user_rooms[user_id]
            if room_id in self.rooms:
                self.rooms[room_id].is_active = False
                del self.rooms[room_id]
            del self.user_rooms[user_id]

    async def handle_message(self, user_id: int, data_str: str):
        try:
            data = json.loads(data_str)
        except Exception:
            return

        action = data.get("action")

        if action == "find_match":
            if user_id not in self.waiting_queue:
                self.waiting_queue.append(user_id)
                await self.active_connections[user_id].send_text(json.dumps({
                    "event": "searching_opponent",
                    "status": "waiting"
                }))
                await self.check_matchmaking()

        elif action == "cancel_search":
            if user_id in self.waiting_queue:
                self.waiting_queue.remove(user_id)
                await self.active_connections[user_id].send_text(json.dumps({
                    "event": "search_cancelled"
                }))

        elif action == "submit_answer":
            if user_id in self.user_rooms:
                room_id = self.user_rooms[user_id]
                if room_id in self.rooms:
                    self.rooms[room_id].record_answer(user_id, data)

    async def check_matchmaking(self):
        while len(self.waiting_queue) >= 2:
            p1_id = self.waiting_queue.pop(0)
            p2_id = self.waiting_queue.pop(0)
            
            p1_ws = self.active_connections.get(p1_id)
            p2_ws = self.active_connections.get(p2_id)

            if not p1_ws or not p2_ws:
                continue

            room_id = f"room_{p1_id}_{p2_id}_{random.randint(1000, 9999)}"
            room = GameRoom(room_id, p1_id, p1_ws, p2_id, p2_ws)
            self.rooms[room_id] = room
            self.user_rooms[p1_id] = room_id
            self.user_rooms[p2_id] = room_id

            asyncio.create_task(room.start_game())

manager = WebSocketManager()
