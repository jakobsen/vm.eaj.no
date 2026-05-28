import { animate, stagger } from "motion";

animate([
  [
    '[data-animate="first"]',
    { opacity: 1, y: [-12, 0], scale: [0.92, 1] },
    { delay: stagger(0.1), type: "spring", bounce: 0.4 },
  ],
  [
    '[data-animate="second"]',
    { opacity: 1, y: [-6, 0], scale: [0.98, 1] },
    { delay: stagger(0.04), type: "spring", bounce: 0.25 },
  ],
]);
