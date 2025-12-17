import { useState, useEffect, useCallback } from 'react';
import Navbar from './components/Navbar';
import { FaEdit } from "react-icons/fa";
import { RiDeleteBin5Line } from "react-icons/ri";
import { v4 as uuidv4 } from 'uuid';
import tablet from './components/tablet.png';
import './App.css';

function App() {
  const [todo, setTodo] = useState("");
  const [todos, setTodos] = useState([]);
  const [editId, setEditId] = useState(null);
  const [showFinished, setShowFinished] = useState(true);
  const [deletingId, setDeletingId] = useState(null);

  // ✅ Use environment variable from .env file
  const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:5000";

  // 🔹 Fetch all todos
  const fetchTodos = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos`);
      const data = await response.json();
      setTodos(data);
    } catch (err) {
      console.error("Error fetching todos:", err);
    }
  }, [API_BASE_URL]);

  useEffect(() => {
    fetchTodos();
  }, [fetchTodos]);

  // 🔹 Add new todo
  const handleAdd = async () => {
    if (todo.trim().length <= 3) return;
    const newTodo = { id: uuidv4(), todo, isCompleted: false };

    try {
      const response = await fetch(`${API_BASE_URL}/todos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTodo),
      });
      const data = await response.json();
      setTodos([...todos, data]);
      setTodo("");
    } catch (err) {
      console.error("Error adding todo:", err);
    }
  };

  // 🔹 Delete todo
  const handleDelete = async (e, id) => {
    setDeletingId(id);
    try {
      await fetch(`${API_BASE_URL}/todos/${id}`, { method: 'DELETE' });
      setTodos(todos.filter(item => item.id !== id));
    } catch (err) {
      console.error("Error deleting todo:", err);
    } finally {
      setDeletingId(null);
    }
  };

  // 🔹 Edit todo
  const handleEdit = (e, id) => {
    e.preventDefault();
    const t = todos.find((i) => i.id === id);
    if (t) {
      setTodo(t.todo);
      setEditId(id);
    }
  };

  // 🔹 Update todo
  const handleUpdate = async () => {
    if (!todo.trim() || !editId) return;
    const updatedTodo = { todo };

    try {
      const response = await fetch(`${API_BASE_URL}/todos/${editId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedTodo),
      });
      const data = await response.json();
      setTodos(todos.map((item) => item.id === editId ? data : item));
      setTodo("");
      setEditId(null);
    } catch (err) {
      console.error("Error updating todo:", err);
    }
  };

  // 🔹 Toggle complete
  const handleCheckbox = async (e) => {
    const id = e.target.name;
    const index = todos.findIndex(item => item.id === id);
    const newTodos = [...todos];
    newTodos[index].isCompleted = !newTodos[index].isCompleted;

    try {
      const updatedTodo = { isCompleted: newTodos[index].isCompleted };
      await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedTodo),
      });
      setTodos(newTodos);
    } catch (err) {
      console.error("Error updating checkbox:", err);
    }
  };

  const toggleFinished = () => setShowFinished(!showFinished);
  const handleChange = (e) => setTodo(e.target.value);

  return (
    <>
      <Navbar />
      <div className="app-container">
        <div className="header">
          <img src={tablet} alt="Tablet" className="tablet-img" />
          <h1 className="title">morTodo</h1>
        </div>

        <div className="add-section">
          <h2>{editId ? 'Edit a Todo' : 'Add a Todo'}</h2>
          <div className="input-group">
            <input
              type="text"
              value={todo}
              onChange={handleChange}
              placeholder="Enter your todo"
            />
            <button
              onClick={editId ? handleUpdate : handleAdd}
              disabled={todo.length <= 3}
            >
              {editId ? 'Update' : 'Add'}
            </button>
          </div>
        </div>

        <div className="filter-section">
          <input
            id="show"
            type="checkbox"
            checked={showFinished}
            onChange={toggleFinished}
          />
          <label htmlFor="show">Show Finished</label>
        </div>

        <hr />

        <h2>Your Todos</h2>
        <div className="todo-list">
          {todos.length === 0 && <div className="no-todo">No Todos to display</div>}
          {todos.map(item =>
            (showFinished || !item.isCompleted) && (
              <div
                key={item.id}
                className={`todo-item ${deletingId === item.id ? 'slide-out' : ''}`}
              >
                <div className="todo-text">
                  <input
                    type="checkbox"
                    name={item.id}
                    checked={item.isCompleted}
                    onChange={handleCheckbox}
                  />
                  <span className={item.isCompleted ? "completed" : ""}>
                    {item.todo}
                  </span>
                </div>
                <div className="todo-buttons">
                  <button onClick={(e) => handleEdit(e, item.id)}>
                    <FaEdit />
                  </button>
                  <button onClick={(e) => handleDelete(e, item.id)}>
                    <RiDeleteBin5Line />
                  </button>
                </div>
              </div>
            )
          )}
        </div>
      </div>
    </>
  );
}

export default App;
