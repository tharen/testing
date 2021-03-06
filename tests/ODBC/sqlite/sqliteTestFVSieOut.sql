.tables
.mode csv
select StandID, RunTitle, KeywordFile, SamplingWt, Variant from FVS_Cases;
select StandID, Year, round(MYBBA,2), round(MYABA,2), round(MYBAR,2), 
  round(newDHt,2), round(newMyBBA,2), round(X1,2)
  from FVS_Compute;
select Count(*) from FVS_TreeList;
select StandID, TopHt, BA, TPA from FVS_Summary;
