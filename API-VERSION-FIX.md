# API Version Mismatch Fix

## Issue
Products list page returned 404 error because the frontend was calling `/api/v2/products` but the backend only supports `/api/v1/products`.

## Root Cause
The `product.service.ts` file had a comment indicating "release 3.2.1 use V2", but the current backend version (3.2.0) only supports v1 API endpoints.

## Fix Applied
Changed the API endpoint in `product.service.ts`:

**Before:**
```typescript
getListOfProducts(params): Observable<any> {
  //release 3.2.1 use V2
  return this.crudService.get(`/v2/products`, params);
}
```

**After:**
```typescript
getListOfProducts(params): Observable<any> {
  //use v1 for compatibility with backend
  return this.crudService.get(`/v1/products`, params);
}
```

## File Modified
- `src/app/pages/catalogue/products/services/product.service.ts`

## Testing
The Angular dev server will automatically recompile. To verify:

1. Wait 5-10 seconds for recompilation
2. Refresh your browser at http://localhost:4200
3. Navigate to: Catalogue Management → Products → Products List
4. Products should now load successfully

## Expected Result
- Products list displays 4 sample products:
  - Olive Table ($199.00)
  - Chair ($99.00)
  - Chair Beige ($119.00)
  - Genuine Chair ($249.99)

## Verification Command
```bash
curl "http://localhost:8080/api/v1/products?store=DEFAULT&lang=en&count=20&page=0"
```

Should return JSON with products array.

## Notes
- Backend version: Shopizer 3.2.0
- Backend supports: `/api/v1/*` endpoints
- Frontend was configured for: `/api/v2/*` (future version)
- This fix ensures compatibility with current backend version
