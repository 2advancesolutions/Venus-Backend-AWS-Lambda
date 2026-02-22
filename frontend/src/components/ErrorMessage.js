import React from 'react';
import './ErrorMessage.css';

const ErrorMessage = ({ message, onRetry }) => {
  return (
    <div className="error-message">
      <div className="error-icon">⚠️</div>
      <h3>Oops! Something went wrong</h3>
      <p className="error-text">{message}</p>
      <button onClick={onRetry} className="retry-button">
        Try Again
      </button>
    </div>
  );
};

export default ErrorMessage;
