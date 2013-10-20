import os

from flask import Flask, Response, json, render_template, url_for

from flask.ext.restful import Api, Resource, abort, fields, marshal_with,\
    reqparse
from flask.ext.sqlalchemy import SQLAlchemy


# config
DEBUG = True
SECRET_KEY = 'secret key'
SQLALCHEMY_DATABASE_URI = 'sqlite:///database.db'

# create the app and register extensions
app = Flask(__name__)
app.config.from_object(__name__)

api = Api(app)
db  = SQLAlchemy(app)


# fields for RESTful object serilization
movie_fields = {
    'id': fields.Integer,
    'year': fields.String,
    'title': fields.String,
    'watched': fields.Boolean
}


# helper
def abort_if_movie_doesnt_exist(id):
    if not Movie.query.get(id):
        abort(404, message="Movie {} doesn't exist".format(id))

parser = reqparse.RequestParser()
parser.add_argument('year', type=str, location='json')
parser.add_argument('title', type=str, location='json')


# models
class Movie(db.Model):
    __tablename__ = 'movies'

    id = db.Column(db.Integer, primary_key=True)
    year = db.Column(db.String())
    title = db.Column(db.String(), unique=True)
    watched = db.Column(db.Boolean())

    def __init__(self, year, title):
        self.year = year
        self.title = title
        self.watched = False

    def __repr__(self):
        return '<Movie %r>' % self.title


# RESTful views
class MovieListAPI(Resource):
    @marshal_with(movie_fields)
    def get(self, **kwargs):
        return Movie.query.all()

    @marshal_with(movie_fields)
    def post(self):
        args = parser.parse_args()
        movie = Movie(args['year'], args['title'])
        db.session.add(movie)
        db.session.commit()
        return movie, 201


class MovieAPI(Resource):
    @marshal_with(movie_fields)
    def get(self, id, **kwargs):
        abort_if_movie_doesnt_exist(id)
        return Movie.query.get(id)

    @marshal_with(movie_fields)
    def put(self, id):
        abort_if_movie_doesnt_exist(id)
        args = parser.parse_args()
        movie = Movie.query.get(id)
        movie.title = args['title']
        db.session.commit()
        return movie, 201

    def delete(self, id):
        abort_if_movie_doesnt_exist(id)
        movie = Movie.query.get(id)
        db.session.delete(movie)
        db.session.commit()
        return '', 204


# views
@app.route('/')
def index():
    return render_template('index.html')


# @app.route('/movies')
# def movies():
#     file = os.path.join(app.static_folder, 'movies.json')
#     with open(file, 'r') as f:
#         content = f.read()
#     response = Response(response=content, status=200,
#                         mimetype='application/json')
#     return response


# RESTful API routing
api.add_resource(MovieListAPI, '/api/movies')
api.add_resource(MovieAPI, '/api/movies/<int:id>')


if __name__ == '__main__':
    app.run()
