var createError = require('http-errors');
var path = require('path');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser')
var logger = require('morgan');
var express = require('express');
var mongoose = require('mongoose');
var cors = require('cors')
var expressValidator  = require('express-validator');//req.checkbody()
const mongoConfig = require('./configs/mongo-config')
var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

// Try connecting to MongoDB; if it fails, fall back to an in-memory MongoDB (for local dev/test)
async function connectWithFallback() {
  try {
    await mongoose.connect(mongoConfig, { useNewUrlParser: true, useCreateIndex: true, useUnifiedTopology: true });
    console.log('connect mongodb success');
  } catch (err) {
    console.warn('Failed to connect to MongoDB at', mongoConfig, '\nError:', err && err.message);
    console.warn('Falling back to in-memory MongoDB for local development...');
    try {
      // lazy-require so this project can still be used without mongodb-memory-server if not installed
      const { MongoMemoryServer } = require('mongodb-memory-server');
      const mongod = await MongoMemoryServer.create();
      // getUri may be sync or async depending on version; handle both
      let uri;
      try {
        uri = mongod.getUri && typeof mongod.getUri === 'function' ? await mongod.getUri() : mongod.getUri;
      } catch (uerr) {
        // fallback - some versions expose uri property or getConnectionString
        uri = mongod.uri || (mongod.getConnectionString && await mongod.getConnectionString());
      }
      if (typeof uri !== 'string') {
        throw new Error('Could not determine in-memory MongoDB uri: ' + JSON.stringify(uri));
      }
      await mongoose.connect(uri, { useNewUrlParser: true, useCreateIndex: true, useUnifiedTopology: true });
      console.log('connected to in-memory mongodb');
      // keep reference so it isn't GC'd (optional)
      process._mongod = mongod;
    } catch (memErr) {
      console.error('Failed to start in-memory MongoDB. Please install MongoDB or add the dependency mongodb-memory-server.');
      console.error(memErr);
      // rethrow to keep original behavior (app will exit)
      throw memErr;
    }
  }
}

connectWithFallback().catch(function(e){
  // If both real MongoDB and in-memory fallback fail, exit so the developer can fix environment
  console.error('Could not initialize any MongoDB instance. Exiting.');
  process.exit(1);
});

var app = express()
app.use(cors())

// Express validator
app.use(expressValidator({
  errorFormatter: function(param, msg, value) {
    var namespace = param.split('.'),
    root          = namespace.shift(),
    formParam     = root;

    // iterate remaining namespace parts correctly
    while(namespace.length) {
      formParam += '[' + namespace.shift() + ']';
    }
    return {
      param : formParam,
      msg   : msg,
      value : value
    };
  }
}));

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

//set static dir
app.use(express.static(path.join(__dirname, 'public')));

//routers
app.use('/', indexRouter);
app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // console.log(err);
  res.status(err.status || 500).json(err);
});

module.exports = app;
