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
    '_id': fields.Integer,
    '_tmdb_id': fields.Integer,
    '_year': fields.String,
    '_title': fields.String,
    '_watched': fields.Boolean
}


# helper
def abort_if_movie_doesnt_exist(_id):
    if not Movie.query.get(_id):
        abort(404, message="Movie {} doesn't exist".format(_id))

parser = reqparse.RequestParser()
parser.add_argument('_tmdb_id', type=int, location='json')
parser.add_argument('_year', type=str, location='json')
parser.add_argument('_title', type=str, location='json')


# models
class Movie(db.Model):
    __tablename__ = 'movies'

    _id = db.Column(db.Integer, primary_key=True)
    _tmdb_id = db.Column(db.Integer)
    _year = db.Column(db.String())
    _title = db.Column(db.String(), unique=True)
    _watched = db.Column(db.Boolean())

    def __init__(self, _tmdb_id, _year, _title):
        self._tmdb_id = _tmdb_id
        self._year = _year
        self._title = _title
        self._watched = False

    def __repr__(self):
        return '<Movie %r>' % self._title


# RESTful views
class MovieListAPI(Resource):
    @marshal_with(movie_fields)
    def get(self, **kwargs):
        return Movie.query.all()

    @marshal_with(movie_fields)
    def post(self):
        args = parser.parse_args()
        movie = Movie(args['_tmdb_id'], args['_year'], args['_title'])
        db.session.add(movie)
        db.session.commit()
        return movie, 201


class MovieAPI(Resource):
    @marshal_with(movie_fields)
    def get(self, _id, **kwargs):
        abort_if_movie_doesnt_exist(_id)
        return Movie.query.get(_id)

    @marshal_with(movie_fields)
    def put(self, _id):
        abort_if_movie_doesnt_exist(_id)
        args = parser.parse_args()
        movie = Movie.query.get(_id)
        movie._tmdb_id = args['_tmdb_id']
        movie._year = args['_year']
        movie._title = args['_title']
        db.session.commit()
        return movie, 201

    def delete(self, _id):
        abort_if_movie_doesnt_exist(_id)
        movie = Movie.query.get(_id)
        db.session.delete(movie)
        db.session.commit()
        return '', 204


# views
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def index(path):
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
api.add_resource(MovieAPI, '/api/movies/<int:_id>')


if __name__ == '__main__':
    app.run()
