import { Router } from 'express';
import { submitGrading } from '../controllers/qualityController';

const router = Router();

router.post('/grades', submitGrading);

export default router;
