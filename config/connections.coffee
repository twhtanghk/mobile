module.exports =
  connections:
    mongo:
      adapter: 'sails-mongo'
      driver: 'mongodb'
      url: process.env.DB || 'mongodb://mobile_mongo/mobile'
