import ollama
import chromadb
from typing import List, Tuple
from pypdf import PdfReader

model = "gemma3:27b"
documents = []

# Read PDF and extract text
reader = PdfReader("file.pdf")
for i, page in enumerate(reader.pages):
    documents.append(page.extract_text())

# Initialize ChromaDB
client = chromadb.PersistentClient(path="./chroma_db")  # Persistent storage
collection = client.get_or_create_collection(name="docs3")

print("Generating Embeddings...")
for i, d in enumerate(documents):
    response = ollama.embeddings(model="mistral-nemo", prompt=d)
    embedding = response["embedding"]
    collection.upsert(
        ids=[str(i)],
        embeddings=[embedding],
        documents=[d]
    )
print("Embeddings Generated")

system_prompt = "Strictly Answer only what is being asked"

class ContextualChatbot:
    def generate_response(self, prompt: str, chat_history: List[Tuple[str, str]]):
        context_prompt = "\n".join([f"User: {u}\nAssistant: {a}" for u, a in chat_history])

        # Query knowledge base
        response = ollama.embeddings(prompt=prompt, model="mistral-nemo")
        results = collection.query(query_embeddings=[response["embedding"]], n_results=3)
        data = results['documents'][0][0]

        # Create full prompt
        full_prompt = f"Context:\n{context_prompt}\nUser: {prompt}\nKnowledge Base: {data}"
        
        # Generate response
        full_response = ""
        for chunk in ollama.generate(
            model=model,
            prompt=full_prompt,
            system=system_prompt,
            stream=True,
            options={"temperature": 0.7, "top_p": 0.9}
        ):
            full_response += chunk['response']
        
        return full_response

# CLI Chatbot
chatbot = ContextualChatbot()
chat_history = []

print("\nChatbot Ready! Type 'exit' to quit.\n")

while True:
    user_input = input("User: ")
    if user_input.lower() == "exit":
        print("Goodbye!")
        break
    
    response = chatbot.generate_response(user_input, chat_history)
    chat_history.append((user_input, response))
    print(f"Assistant: {response}\n")
