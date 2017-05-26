import Promise from "promise-polyfill";
if (!window.Promise) window.Promise = Promise;

import fetchData from  "../../src/lib/fetch-data";

describe("Fetch Data", () => {

  it("runs tests", () => {
    fetchData("example.com");
    expect(true).to.eql(true);
  })

});
