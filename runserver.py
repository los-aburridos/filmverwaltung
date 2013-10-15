import os

from flask import Flask, Response, json, render_template, url_for


app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/movies')
def movies():
    file = os.path.join(app.static_folder, 'movies.json')
    with open(file, 'r') as f:
        content = f.read()
    response = Response(response=content, status=200,
                        mimetype='application/json')
    return response


if __name__ == '__main__':
    app.run(debug=True)
