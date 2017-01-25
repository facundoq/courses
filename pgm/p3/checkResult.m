function res = checkResult(label, expected, sorted, raw)
  fprintf('%s ...\n', label);
  params = struct('displaycontextprogress', 0, 'NumericTolerance', 1e-6);
  cmp = comparedata(expected, sorted, [], params);
  if cmp
    rawCmp = comparedata(expected, raw, [], params);
    if rawCmp
      fprintf('%s: OK\n', label);
    else
      fprintf('%s: ok with warnings\n', label);
    end
    res = true;
  else
    fprintf('%s: FAIL\n', label);
    res = false
  end
end
