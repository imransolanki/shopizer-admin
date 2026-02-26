import { TestBed } from "@angular/core/testing";
import { NO_ERRORS_SCHEMA } from '@angular/core';

import { SharedService } from "./shared.service";

describe("SharedServiceService", () => {
  beforeEach(() => TestBed.configureTestingModule({
      schemas: [NO_ERRORS_SCHEMA]
    }));

  it("should be created", () => {
    const service: SharedService = TestBed.inject(SharedService);
    expect(service).toBeTruthy();
  });
});
