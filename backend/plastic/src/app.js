const express = require('express');
const userRouter = require('./routers/user');
const templateRouter = require('./routers/template');
const thingRouter = require('./routers/thing');
const viewRouter = require('./routers/view');
const port = process.env.PORT;
const morgan = require('morgan');
require('./db/db');

const app = express();

app.use(morgan('dev'));
app.use(express.json());

app.use(userRouter);
app.use(templateRouter);
app.use(thingRouter);
app.use(viewRouter);

app.listen(port, () => {
	console.log(`Server running on port ${port}`);
});