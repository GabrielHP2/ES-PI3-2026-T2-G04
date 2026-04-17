import { describe, expect, test } from "@jest/globals";

const functionsUrl =
  "https://southamerica-east1-mescla-invest-fff3b.cloudfunctions.net";

test("endpoint addSampleStartup deve retornar ok", async () => {
  const response = await fetch(functionsUrl + "/showStartupByName");
  const data = await response.json();
  console.log(data);

  expect(response.status).toBe(200);
  expect(data[0]).toBeDefined;
});
