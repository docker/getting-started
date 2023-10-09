if (process.env.MYSQL_HOST) module.exports = require('./mysql');
else module.exports = require('./sqlite');
