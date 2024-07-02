from django.shortcuts import render, redirect
from django.http import JsonResponse
from azure_auth.decorators import azure_auth_required
import requests
import logging
import json

# Configure logging
logging.basicConfig(level=logging.DEBUG)


@azure_auth_required
def call_ollama(request):
    if request.method == "POST":
        user_input = request.POST.get("userInput", "")
        try:
            conversation_history = json.loads(user_input)
        except json.JSONDecodeError as e:
            logging.error("JSONDecodeError: %s", e)
            return JsonResponse({"error": "Invalid input format"}, status=400)

        url = "http://localhost:11434/api/chat"
        headers = {"Content-Type": "application/json"}
        data = {"model": "llama3", "messages": conversation_history, "stream": False}

        logging.debug("Sending data to Ollama API: %s", json.dumps(data, indent=2))

        try:
            response = requests.post(url, json=data, headers=headers)
            response.raise_for_status()
            response_data = response.json()
            logging.debug("Response data: %s", json.dumps(response_data, indent=2))

            ollama_response = response_data.get("message", {}).get("content", "")
            if not ollama_response:
                logging.error("Empty response from Ollama API")
                return JsonResponse({"error": "Empty response from Ollama API"}, status=500)

            return JsonResponse({"response": ollama_response})
        except requests.RequestException as e:
            logging.error("RequestException: %s", e)
            return JsonResponse({"error": str(e)}, status=500)
    else:
        return render(request, "streamingapp/input_form.html")


def redirect_to_ollama(request):
    return redirect("/stream/call-ollama")
