import { Router } from 'express';
import { pushOfflineData, pullUpdates } from '../controllers/syncController';

const router = Router();

router.post('/push', pushOfflineData);
router.get('/pull', pullUpdates);

export default router;
