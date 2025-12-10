(async ()=>{
  try{
    const { MongoMemoryServer } = require('mongodb-memory-server');
    console.log('MongoMemoryServer require ok');
    const mongod = await MongoMemoryServer.create();
    console.log('created mongod', typeof mongod);
    let uri;
    try{ uri = mongod.getUri && typeof mongod.getUri==='function' ? await mongod.getUri() : mongod.getUri }catch(e){ uri = mongod.uri || (mongod.getConnectionString && await mongod.getConnectionString()) }
    console.log('uri:', uri);
    await mongod.stop();
    console.log('stopped');
  }catch(e){
    console.error('ERR', e);
    process.exit(1);
  }
})();