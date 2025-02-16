import openai
import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables from .env file
load_dotenv()

# Get API Key from environment variable
api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    print("Error: OPENAI_API_KEY environment variable not set.")
    exit(1)

# Create OpenAI client using v1.0+ interface
client = OpenAI(api_key=api_key)

try:
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Say hello!"}
        ]
    )
    
    print("API Test Successful!")
    print("Response:", response.choices[0].message.content)
except openai.RateLimitError:
    print("Error: You have exceeded your current quota. Please check your API plan and billing details.")
except openai.AuthenticationError:
    print("Error: Invalid API key. Please check your API key.")
except Exception as e:
    print(f"An error occurred: {e}")
