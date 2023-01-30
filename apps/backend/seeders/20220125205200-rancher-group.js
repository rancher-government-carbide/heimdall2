'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const result = await queryInterface.sequelize.query(
      'SELECT COUNT(id) FROM "Groups" WHERE name = \'rancher\'',
      {type: queryInterface.sequelize.QueryTypes.SELECT}
    );

    if (result[0].count == '0') {
      console.log('No Rancher group exists. Creating...');
      return queryInterface.bulkInsert(
        'Groups',
        [
          {
            name: 'rancher',
            public: false,
            createdAt: new Date(),
            updatedAt: new Date()            
          }
        ],
        {}
      )
    } else {
      console.log('Default Rancher group exists. Skipping creation.');
      return queryInterface.sequelize.query('SELECT 1+1 AS result');
    }
  },
  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Groups', {name: 'rancher'})
  }
}