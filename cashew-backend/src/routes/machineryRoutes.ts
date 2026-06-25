import { Router } from 'express';
import { registerMachine, logTelemetry, logMaintenance } from '../controllers/machineryController';

const router = Router();

router.post('/', registerMachine);
router.post('/telemetry', logTelemetry);
router.post('/maintenance', logMaintenance);

export default router;
