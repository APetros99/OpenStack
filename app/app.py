from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Beautiful People!'

if __name__ == '__main__':
    app.run(host='10.0.2.15', port=5234)