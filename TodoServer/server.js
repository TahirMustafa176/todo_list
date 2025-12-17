const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/todo_list_db';

// ✅ Connect directly to MongoDB (Docker local)
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to local MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

const todoSchema = new mongoose.Schema({
  id: { type: String, required: true },
  todo: { type: String, required: true },
  isCompleted: { type: Boolean, default: false }
});

const Todo = mongoose.model('Todo', todoSchema);

// Routes
app.get('/todos', async (req, res) => {
  try {
    const todos = await Todo.find();
    res.json(todos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/todos', async (req, res) => {
  try {
    const newTodo = new Todo({
      id: req.body.id,
      todo: req.body.todo,
      isCompleted: req.body.isCompleted
    });
    await newTodo.save();
    res.json(newTodo);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/todos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updatedTodo = await Todo.findOneAndUpdate({ id }, req.body, { new: true });
    res.json(updatedTodo);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/todos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await Todo.findOneAndDelete({ id });
    res.json({ message: 'Todo deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
