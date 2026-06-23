from fastapi import FastAPI, HTTPException, Header, Depends
from pydantic import BaseModel
import stripe
import os

app = FastAPI(title="Aura Landing Zone Billing Engine")

# Configure your secure Stripe API environment key
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
API_BEARER_TOKEN = os.getenv("INTERNAL_BILLING_TOKEN")

class VerificationRequest(BaseModel):
    tenant_id: str

def verify_token(authorization: str = Header(None)):
    if not authorization or authorization != f"Bearer {API_BEARER_TOKEN}":
        raise HTTPException(status_status=401, detail="Unauthorized API Token")

@app.post("/v1/verify-subscription")
async def verify_subscription(request: VerificationRequest, dependencies=Depends(verify_token)):
    try:
        # 1. Lookup the customer record mapped to the requesting GitHub Workspace
        customers = stripe.Customer.list(query=f"metadata['tenant_id']:'{request.tenant_id}'")
        if not customers.data:
            raise HTTPException(status_code=402, detail="Customer Profile Missing")
            
        customer_id = customers.data[0].id
        
        # 2. Query Stripe for active or trialing product subscriptions
        subscriptions = stripe.Subscription.list(customer=customer_id, status="active")
        
        if len(subscriptions.data) == 0:
            # Fallback: check for valid trial models
            trialing = stripe.Subscription.list(customer=customer_id, status="trialing")
            if len(trialing.data) == 0:
                raise HTTPException(status_code=402, detail="Payment Subscription Expired/Unpaid")
                
        return {"status": "authorized", "message": "Account payment verified successfully."}
        
    except stripe.error.StripeError as e:
        raise HTTPException(status_code=500, detail=f"Stripe Gateway Communication Failure: {str(e)}")
