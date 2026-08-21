import base64
import json
from typing import Dict, Any

# --- Payme & Click Merchant Konfiguratsiyasi ---
PAYME_MERCHANT_ID = "YOUR_PAYME_MERCHANT_ID"
CLICK_MERCHANT_ID = "YOUR_CLICK_MERCHANT_ID"
CLICK_SERVICE_ID = "YOUR_CLICK_SERVICE_ID"
CLICK_SECRET_KEY = "YOUR_CLICK_SECRET_KEY"

def generate_payme_link(amount_uzs: int, order_id: str) -> str:
    """
    Payme to'lov havolasini (Deep link) generatsiya qilish.
    Summa tiyinda (amount_uzs * 100).
    """
    amount_tiyin = amount_uzs * 100
    params = f"m={PAYME_MERCHANT_ID};ac.order_id={order_id};a={amount_tiyin}"
    encoded_params = base64.b64encode(params.encode("utf-8")).decode("utf-8")
    return f"https://checkout.paycom.uz/{encoded_params}"

def generate_click_link(amount_uzs: int, order_id: str, return_url: str = "quizduel://payment-success") -> str:
    """
    Click to'lov havolasini (Deep link) generatsiya qilish.
    """
    return (
        f"https://my.click.uz/services/pay"
        f"?service_id={CLICK_SERVICE_ID}"
        f"&merchant_id={CLICK_MERCHANT_ID}"
        f"&amount={amount_uzs}"
        f"&transaction_param={order_id}"
        f"&return_url={return_url}"
    )

def handle_payme_webhook(data: Dict[str, Any], db_conn) -> Dict[str, Any]:
    """
    Payme JSON-RPC 2.0 Webhook integratsiyasi.
    """
    method = data.get("method")
    params = data.get("params", {})
    req_id = data.get("id")

    if method == "CheckPerformTransaction":
        return {
            "result": {"allow": True},
            "id": req_id
        }
    elif method == "CreateTransaction":
        return {
            "result": {
                "create_time": 1700000000000,
                "transaction": "payme_txn_" + str(params.get("id", "1")),
                "state": 1,
                "receivers": None
            },
            "id": req_id
        }
    elif method == "PerformTransaction":
        # Mahsulotni foydalanuvchiga taqdim etish logikasi
        return {
            "result": {
                "transaction": "payme_txn_" + str(params.get("id", "1")),
                "perform_time": 1700000000000,
                "state": 2
            },
            "id": req_id
        }
    elif method == "CheckTransaction":
        return {
            "result": {
                "create_time": 1700000000000,
                "perform_time": 1700000000000,
                "cancel_time": 0,
                "transaction": "payme_txn_" + str(params.get("id", "1")),
                "state": 2,
                "reason": None
            },
            "id": req_id
        }
    return {"error": {"code": -32601, "message": "Method not found"}, "id": req_id}

def handle_click_webhook(data: Dict[str, Any], db_conn) -> Dict[str, Any]:
    """
    Click Prepare & Complete API integratsiyasi.
    """
    action = data.get("action") # 0 = Prepare, 1 = Complete
    click_trans_id = data.get("click_trans_id")
    merchant_trans_id = data.get("merchant_trans_id")

    if action == 0 or action == "0":
        return {
            "click_trans_id": click_trans_id,
            "merchant_trans_id": merchant_trans_id,
            "merchant_prepare_id": "prep_" + str(click_trans_id),
            "error": 0,
            "error_note": "Success"
        }
    elif action == 1 or action == "1":
        # To'lov yakunlandi: foydalanuvchi hisobiga VIP yoki tangalarni qo'shish
        return {
            "click_trans_id": click_trans_id,
            "merchant_trans_id": merchant_trans_id,
            "merchant_confirm_id": "conf_" + str(click_trans_id),
            "error": 0,
            "error_note": "Success"
        }
    return {"error": -1, "error_note": "Action unknown"}
