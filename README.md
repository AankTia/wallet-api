# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
rvm use 3.0.4

gem install rails -v 6.1.6
rvm gemset create wallet-api
rvm 3.0.4@wallet-api --create

* System dependencies

* Configuration

* Database creation

docker pull tiawidi/mongo:6.0.2

* Database initialization
mongosh --host localhost --port 27017 -u "root.admin" -p "root.admin.password" --authenticationDatabase admin
use wallet
db.createUser({user: "tw", pwd: "tw123", roles: ["readWrite"]})

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
