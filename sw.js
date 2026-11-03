// 오프라인 지원: 한 번 열어본 뒤에는 데이터가 없어도 도시 정보를 볼 수 있어요.
// 정보를 고쳐서 다시 올릴 때는 아래 버전 숫자를 하나 올려주세요 (예: v2 → v3).
const CACHE = "tapcheck-v1";
const CORE = [
  "./",
  "./index.html",
  "./privacy.html",
  "./config.js",
  "./manifest.webmanifest",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(CORE)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  // 제보 저장소(Supabase) 요청은 캐시하지 않아요.
  if (url.hostname.endsWith("supabase.co")) return;

  // 페이지와 같은 사이트 파일: 인터넷이 되면 최신 버전, 안 되면 저장해둔 버전
  if (url.origin === self.location.origin) {
    e.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(req, copy));
          return res;
        })
        .catch(() => caches.match(req).then((r) => r || caches.match("./index.html")))
    );
    return;
  }

  // 글꼴·라이브러리 같은 외부 파일: 저장해둔 게 있으면 바로 쓰고, 뒤에서 새로 받아요.
  e.respondWith(
    caches.match(req).then((cached) => {
      const net = fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(req, copy));
          return res;
        })
        .catch(() => cached);
      return cached || net;
    })
  );
});
