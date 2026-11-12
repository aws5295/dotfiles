import { test } from "node:test";
import assert from "node:assert/strict";
import { ONE_DARK_PRO, SUMMIT, palette, sendLabel } from "../palette.js";

test("summit palette", () => {
  assert.deepEqual(palette("summit", {}), SUMMIT);
  assert.equal(SUMMIT.added, "#7fd49a");
});

test("unknown palette falls back", () => {
  assert.deepEqual(palette(undefined, {}), ONE_DARK_PRO);
});

test("default label unchanged", () => {
  assert.equal(sendLabel(null), "Submit review");
  assert.equal(sendLabel({}), "Submit review");
});

test("custom label", () => {
  assert.equal(sendLabel({ send_label: "Send comments" }), "Send comments");
});
