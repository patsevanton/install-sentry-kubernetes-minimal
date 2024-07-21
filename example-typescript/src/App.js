import React from 'react';
import * as Sentry from '@sentry/react';
import { Integrations } from '@sentry/tracing';

// Инициализация Sentry
Sentry.init({
  dsn: 'YOUR_SENTRY_DSN_HERE', // Замените на ваш DSN
  integrations: [new Integrations.BrowserTracing()],
  tracesSampleRate: 1.0,
});

function ErrorButton() {
  function throwError() {
    throw new Error('This is a test error from React');
  }

  return (
    <button onClick={throwError}>
      Throw Error
    </button>
  );
}

function App() {
  return (
    <div className="App">
      <h1>Sentry Example</h1>
      <ErrorButton />
    </div>
  );
}

export default Sentry.withProfiler(App);