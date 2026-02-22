import React from 'react';
import './UserList.css';

const UserList = ({ users }) => {
  if (users.length === 0) {
    return (
      <div className="no-users">
        <p>📭 No users found</p>
      </div>
    );
  }

  return (
    <div className="user-list">
      <h2 className="user-list-title">User Directory</h2>
      <div className="user-grid">
        {users.map((user) => (
          <div key={user.id} className="user-card">
            <div className="user-avatar">
              {user.name.split(' ').map(n => n[0]).join('').toUpperCase()}
            </div>
            <div className="user-info">
              <h3 className="user-name">{user.name}</h3>
              <p className="user-email">{user.email}</p>
              {user.role && <span className="user-role">{user.role}</span>}
            </div>
            <div className="user-meta">
              <span className="user-id">ID: {user.id}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default UserList;
