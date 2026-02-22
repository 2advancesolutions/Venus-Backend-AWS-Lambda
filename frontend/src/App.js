import React, { useState, useEffect } from 'react';
import './App.css';
import UserList from './components/UserList';
import ErrorMessage from './components/ErrorMessage';
import LoadingSpinner from './components/LoadingSpinner';

// API URL - Replace with your deployed Lambda URL
const API_URL = process.env.REACT_APP_API_URL || 'https://YOUR_API_GATEWAY_URL/dev/users';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);

  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetch(API_URL);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.success && data.users) {
        setUsers(data.users);
        setLastUpdated(new Date(data.timestamp));
      } else {
        throw new Error('Invalid response format');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleRefresh = () => {
    fetchUsers();
  };

  return (
    <div className="app">
      <header className="app-header">
        <h1>🌟 Venus Users Management</h1>
        <p className="subtitle">Powered by AWS Lambda + React</p>
      </header>

      <main className="app-main">
        <div className="controls">
          <button 
            onClick={handleRefresh} 
            disabled={loading}
            className="refresh-button"
          >
            {loading ? '⟳ Loading...' : '🔄 Refresh Users'}
          </button>
          
          {lastUpdated && (
            <span className="last-updated">
              Last updated: {lastUpdated.toLocaleTimeString()}
            </span>
          )}
        </div>

        {loading && <LoadingSpinner />}
        {error && <ErrorMessage message={error} onRetry={handleRefresh} />}
        {!loading && !error && <UserList users={users} />}
      </main>

      <footer className="app-footer">
        <p>Built with React + AWS Lambda | {users.length} users total</p>
      </footer>
    </div>
  );
}

export default App;
