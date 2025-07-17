const express = require('express');
const router = express.Router();

const database = require('./database');
const onvif = require('./onvif');
const video = require('./video');

router.use(database); // ✅ database는 Express Router
router.use(onvif);


module.exports = { router }; // ✅ 이건 OK
