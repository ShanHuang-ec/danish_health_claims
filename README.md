# danish_health_claims

So far, this project only organizes some claims labels under the data_management folder. The R script there (read_data.R):
1. Reads in a big excel data set with claim codes (SSSY_documentation.xls)
2. Assigns right data types
3. Brings it into normal form (delete duplicates)
4. Translates label(s) from Danish to English using googletrans in python
5. Save modified data

## FIX:
- Translate other labels; one column so far, add sleep
- pre-commit hooks...

## Notes
I would like to use this repo for modeling/simulations and to try out new tools in the future.
