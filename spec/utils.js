'use babel';
'use strict';

import path from 'path';

const utils = {
  getDB: function() {
    // db.updateFilepath(utils.dbPath());
    // spyOn(db, 'readFile').andCallFake((callback) => {
    //   const props = {
    //     test: {
    //       _id: 'test',
    //       title: 'Test',
    //       paths: ['/Users/test'],
    //       icon: 'icon-test',
    //     }
    //   };
    //
    //   callback(props);
    // });

    // return db;
  },

  dbPath: function() {
    const specPath = path.join(__dirname, 'db');
    const id = utils.id();

    return `${specPath}/${id}.cson`;
  },

  id: function() {
    return '_' + Math.random().toString(36).substr(2, 9);
  }
};

export default utils;
