import { describe, expect, test } from "@jest/globals";

const functionsUrl =
  "https://southamerica-east1-mescla-invest-fff3b.cloudfunctions.net";

describe("Test Functions endpoint", () => {
  test("endpoint showStartupByName deve retornar ok", async () => {
    const response = await fetch(functionsUrl + "/showStartupByName");
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data).toBeDefined();
  });

  test("endpoint addSampleStartup deve retornar ok", async () => {
    const response = await fetch(functionsUrl + "/addSampleStartup", {
      method: "POST",
    });
    const data = await response.json();

    expect(response.status).toBe(201);
    expect(data.message).toBe("Startup exemplo inserida com sucesso.");
    expect(data.id).toBeDefined();
  });

  test("endpoint deleteSampleStartup deve retornar ok", async () => {
    const response = await fetch(functionsUrl + "/deleteStartup", {
      method: "DELETE",
    });
    const data = await response.json();

    expect(response.status).toBe(201);
    expect(data.message).toBe("Startup provavelmente excluida.");
  });
});
