{{flutter_js}}
{{flutter_build_config}}

// Preload essential assets
const preloadAssets = [
  '/flutter.js',
  '/main.dart.js',
  'splash/boy.jpg'
];

preloadAssets.forEach(asset => {
  const link = document.createElement('link');
  link.rel = 'preload';
  link.href = asset;
  link.as = asset.endsWith('.js') ? 'script' : (asset.endsWith('.jpg') ? 'image' : 'fetch');
  link.crossOrigin = 'anonymous';
  document.head.appendChild(link);
});

let flutterReady = false;
let engineInitialized = false;
let startAppQueued = false;
let flutterWidgetsLoaded = false;

function getCanvasKitMaximumSurfaces() {

  const memory = navigator.deviceMemory || 4;
  console.log('Memory:', memory);
  const cpuCores = navigator.hardwareConcurrency || 2;
  console.log('CPU cores:', cpuCores);
  const isLowEndDevice = () => {
    return memory <= 2 || cpuCores <= 2 || !window.WebGLRenderingContext;
  };


  const isHighEndDevice = () => {
    return memory >= 8 && cpuCores >= 6 && 'gpu' in navigator;
  };

  const isMobileDevice = () => {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  };


  if (isLowEndDevice()) {
    return 2;
  } else if (isHighEndDevice() && !isMobileDevice()) {
    return 8;
  } else if (isMobileDevice()) {
    return 4;
  } else {
    return 5;
  }
}

async function initializeApp() {
  showButtonLoader('Initializing...');

  try {
    const searchParams = new URLSearchParams(window.location.search);
    const forceCanvaskit = searchParams.get('force_canvaskit') === 'true';
    const isDebug = searchParams.get('debug') === 'true' ||
                    window.location.hostname === 'localhost' ||
                    window.location.hostname === '127.0.0.1';

    const userConfig = {
      renderer: forceCanvaskit ? 'canvaskit' : '',
      canvasKitVariant: 'auto',
      canvasKitMaximumSurfaces: getCanvasKitMaximumSurfaces(),
      canvasKitForceCpuOnly: false,
      debugShowSemanticNodes: isDebug
    };

    if (typeof ChannelBuffers !== 'undefined') {
      ChannelBuffers.instance.setCapacity('flutter/lifecycle', 100);
    }

    await _flutter.loader.load({
      config: userConfig,
      serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
      },
      onEntrypointLoaded: async function(engineInitializer) {
        console.log('Flutter entrypoint loaded');
        window.appRunner = await engineInitializer.initializeEngine();
        engineInitialized = true;

        if (shouldAutoStartApp()) {
          startApp();
        } else {
          showLandingPage();
        }

        if (startAppQueued) {
          startApp();
        }
      }
    });

    hideButtonLoader();
  } catch (error) {
    console.error('Error during initialization:', error);
    console.error('Stack trace:', error.stack);
    hideButtonLoader();
    showErrorMessage('Failed to initialize. Please try again. Error: ' + error.message);
  }
}

function shouldAutoStartApp() {
  return window.location.search !== '' ||
         (window.location.hash !== '' && window.location.hash !== '#') ||
         localStorage.getItem('hasVisited') === 'true';
}

function hideLoadingElements() {
  const landingPage = document.getElementById('landing-page');
  if (landingPage) {
    landingPage.style.display = 'none';
  }
  document.body.style.overflow = 'auto';
}

function showLandingPage() {
  const landingPage = document.getElementById('landing-page');
  if (landingPage) {
    landingPage.style.display = 'block';
  }
  const exploreEventsButton = document.getElementById('explore-events-button');
  if (exploreEventsButton) {
    exploreEventsButton.disabled = false;
    exploreEventsButton.classList.remove('disabled');
  }
}

function showButtonLoader(loadingTextContent = 'Loading Events...') {
  const button = document.getElementById('explore-events-button');
  const buttonText = button.querySelector('span');
  const buttonLoader = button.querySelector('.button-loader');
  const loadingText = button.querySelector('.loading-text');

  button.classList.add('loading');
  buttonLoader.style.display = 'block';
  loadingText.style.display = 'block';
  loadingText.textContent = loadingTextContent;
  buttonText.style.visibility = 'hidden';
}

function hideButtonLoader() {
  const button = document.getElementById('explore-events-button');
  const buttonText = button.querySelector('span');
  const buttonLoader = button.querySelector('.button-loader');
  const loadingText = button.querySelector('.loading-text');

  button.classList.remove('loading');
  buttonLoader.style.display = 'none';
  loadingText.style.display = 'none';
  buttonText.style.visibility = 'visible';
}

function showErrorMessage(message) {
  const errorElement = document.getElementById('error-message');
  if (errorElement) {
    errorElement.textContent = message;
    errorElement.style.display = 'block';
  }
}

window.runFlutterApp = async function() {
  if (!window.appRunner) {
    console.error('Flutter engine not initialized');
    return;
  }
  console.log('Running app');
  await window.appRunner.runApp();
  localStorage.setItem('hasVisited', 'true');
  flutterReady = true;
}

window.startApp = function() {
  showButtonLoader('Loading Events...');
  if (engineInitialized) {
    if (flutterReady) {
      if (flutterWidgetsLoaded) {
        setTimeout(hideAllLoadingElements, 1);
      } else {
        console.log('Flutter widgets not yet loaded. Waiting...');
      }
    } else {
      window.runFlutterApp().then(() => {
        if (flutterWidgetsLoaded) {
          setTimeout(hideAllLoadingElements, 1);
        } else {
          console.log('Flutter widgets not yet loaded. Waiting...');
        }
      });
    }
  } else {
    console.log('Engine not yet initialized. Queueing app start.');
    startAppQueued = true;
  }
}

window.onFlutterWidgetsLoaded = function() {
  console.log('Flutter widgets loaded');
  flutterWidgetsLoaded = true;

  if (flutterReady) {
    setTimeout(hideAllLoadingElements, 1);
  }
}

function hideAllLoadingElements() {
  hideLoadingElements();
  hideButtonLoader();
}

// Start initialization immediately
const initPromise = initializeApp();
const timeoutPromise = new Promise((_, reject) =>
  setTimeout(() => reject(new Error('Initialization timed out')), 30000)
);

Promise.race([initPromise, timeoutPromise])
  .catch(error => {
    console.error('Initialization failed:', error);
    hideButtonLoader();
    showErrorMessage('Initialization timed out. Please refresh and try again.');
  });