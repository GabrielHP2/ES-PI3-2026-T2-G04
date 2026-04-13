// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import express, {Request, Response} from "express";

const app = express();
const port = 3000;

app.use(express.json());


app.listen(port, () => {
    console.log(`Servidor rodando na porta ${port}`);
});