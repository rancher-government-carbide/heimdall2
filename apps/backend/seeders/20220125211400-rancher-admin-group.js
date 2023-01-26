'use strict';

async function getAdminId(queryInterface) {
  return await queryInterface.sequelize.query(
    'SELECT id FROM "Users" WHERE role = \'admin\'',
    {type: queryInterface.sequelize.QueryTypes.SELECT}
  )
}

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const adminId = await getAdminId(queryInterface)

    const alreadyMapped = await queryInterface.sequelize.query(
      'SELECT COUNT(id) FROM "GroupUsers" WHERE "userId" = ?',
      {
        type: queryInterface.sequelize.QueryTypes.SELECT,
        replacements: [adminId.id]
      }
    )

    if (alreadyMapped[0].count == '0') {
      console.log('Default admin not mapped to default rancher group. Mapping now...');
      const groupId = await queryInterface.sequelize.query(
        'SELECT id FROM "Groups" WHERE name = \'rancher\'',
        {type: queryInterface.sequelize.QueryTypes.SELECT}
      )

      return queryInterface.bulkInsert(
        'GroupUsers',
        [
          {
            userId: adminId.id,
            groupId: groupId.id,
            role: 'owner',
            createdAt: new Date(),
            updatedAt: new Date()
          }
        ]
      )
    } else {
      console.log('Default admin already mapped to default rancher group. Nothing to do.')
      return queryInterface.sequelize.query('SELECT 1+1 AS result');
    }
  },
  down: async (queryInterface, Sequelize) => {
    const adminId = await getAdminId(queryInterface)

    return queryInterface.bulkDelete('GroupUsers', {id: adminId.id})
  }
}