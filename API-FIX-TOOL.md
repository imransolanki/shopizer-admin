# API Fix Tool - Documentation

## Overview
A diagnostic tool that tests API endpoints, finds correct alternatives, and locates service files that need fixing.

## Location
`./api-fix-tool.sh`

## Usage

### Basic Usage
```bash
./api-fix-tool.sh "http://localhost:8080/api/v1/endpoint"
```

### Multiple APIs
```bash
./api-fix-tool.sh \
  "http://localhost:8080/api/v1/product?count=200&lang=en&page=0" \
  "http://localhost:8080/api/v2/categories" \
  "http://localhost:8080/api/v1/orders"
```

## Features

### 1. API Testing
- Tests each endpoint with curl
- Reports HTTP status code
- Identifies working vs failing APIs

### 2. Endpoint Discovery
- Automatically tries common variations:
  - Original endpoint
  - Plural form (adds 's')
  - Singular form (removes 's')
- Reports working alternatives

### 3. Service File Location
- Searches TypeScript files for endpoint usage
- Shows exact file and line number
- Helps identify what needs to be fixed

### 4. Summary Report
- Total APIs tested
- Number of failures
- Number of fixes found
- List of all failed APIs

## Example Output

```
==========================================
API Diagnostic and Fix Tool
==========================================

==========================================
Processing: http://localhost:8080/api/v1/product?count=200&lang=en&page=0
==========================================
Testing: http://localhost:8080/api/v1/product?count=200&lang=en&page=0
❌ Status: 404 - FAILED

🔍 Searching for correct endpoint...
✅ Found working endpoint: http://localhost:8080/api/v1/products
   Full URL: http://localhost:8080/api/v1/products?count=10&lang=en&page=0

🔍 Searching for service file using: v1/product
📁 Found in files:
   src/app/pages/catalogue/products/services/product.service.ts:    return this.crudService.get(`/v1/product?count=200&lang=en&page=0`)

==========================================
Summary
==========================================
Total APIs tested: 1
Failed APIs: 1
Fixed APIs: 1

Failed APIs:
  ❌ http://localhost:8080/api/v1/product?count=200&lang=en&page=0
```

## How It Works

### Step 1: Test Original Endpoint
```bash
curl -s -o /dev/null -w "%{http_code}" "$endpoint"
```

### Step 2: Try Variations
If original fails, tries:
- `/api/v1/product` → `/api/v1/products` (plural)
- `/api/v1/products` → `/api/v1/product` (singular)

### Step 3: Search Service Files
```bash
grep -r "/$path" src --include="*.ts"
```

### Step 4: Report Results
- ✅ Working endpoints
- ❌ Failed endpoints
- 📁 Files to fix
- 🔧 Suggested changes

## Common Issues Fixed

### Issue 1: Singular vs Plural
**Problem:** `/api/v1/product` returns 404  
**Solution:** Use `/api/v1/products`

**Files to Update:**
- `product.service.ts`
- Any component using the endpoint

### Issue 2: API Version Mismatch
**Problem:** `/api/v2/endpoint` returns 404  
**Solution:** Use `/api/v1/endpoint`

### Issue 3: Missing Parameters
**Problem:** Endpoint requires specific parameters  
**Solution:** Tool shows working example with parameters

## Integration with Fix Process

### 1. Run Diagnostic
```bash
./api-fix-tool.sh "http://localhost:8080/api/v1/product?count=200&lang=en&page=0"
```

### 2. Review Output
- Note the working endpoint
- Note the files that need fixing

### 3. Apply Fix
```typescript
// Before
return this.crudService.get(`/v1/product?count=200&lang=en&page=0`)

// After
return this.crudService.get(`/v1/products?count=200&lang=en&page=0`)
```

### 4. Verify Fix
```bash
./api-fix-tool.sh "http://localhost:8080/api/v1/products?count=200&lang=en&page=0"
```

## Real-World Example

### Problem
Create product page fails with 404 error for:
```
http://localhost:8080/api/v1/product?count=200&lang=en&page=0
```

### Diagnosis
```bash
./api-fix-tool.sh "http://localhost:8080/api/v1/product?count=200&lang=en&page=0"
```

**Output:**
- ❌ Original endpoint fails (404)
- ✅ Found working: `/api/v1/products`
- 📁 Found in: `product.service.ts` lines 87, 90

### Fix Applied
Changed in `product.service.ts`:
```typescript
// Line 87
getProductByOrder(): Observable<any> {
  return this.crudService.get(`/v1/products?count=200&lang=en&page=0`)
}

// Line 90
getProductOrderById(id): Observable<any> {
  return this.crudService.get(`/v1/products?category=${id}&count=200&lang=en&page=0`)
}
```

### Verification
```bash
./api-fix-tool.sh "http://localhost:8080/api/v1/products?count=200&lang=en&page=0"
```

**Result:** ✅ Status: 200 - OK

## Limitations

1. **Only tests GET requests** - POST/PUT/DELETE not tested
2. **Limited variations** - Only tries singular/plural
3. **No authentication** - Assumes public endpoints
4. **Basic search** - May miss complex endpoint patterns

## Future Enhancements

- Support for POST/PUT/DELETE methods
- Test with authentication headers
- More endpoint variations (kebab-case, camelCase)
- Automatic code fixing
- Integration with git diff
- API documentation generation

## Troubleshooting

### Tool doesn't find service files
**Cause:** Wrong directory  
**Solution:** Run from shopizer-admin root

### All endpoints fail
**Cause:** Backend not running  
**Solution:** Start backend with `docker start shopizer-backend`

### False positives
**Cause:** Endpoint requires authentication  
**Solution:** Manually verify with proper headers

## Summary

The API Fix Tool:
- ✅ Diagnoses failing endpoints
- ✅ Finds working alternatives
- ✅ Locates files to fix
- ✅ Provides clear output
- ✅ Supports multiple APIs at once
- ✅ Simple bash script, no dependencies

**Status:** Production ready and tested
