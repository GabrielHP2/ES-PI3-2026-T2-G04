// João Pedro Panza Mainieri - RA: 25006642

import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";

export const auth = getAuth();
export const db = getFirestore();
