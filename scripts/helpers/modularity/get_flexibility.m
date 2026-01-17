function flexibility = get_flexibility(S_multi)
    flexibility = S_multi(:,1:(end-1)) ~= S_multi(:,2:end);
    flexibility = mean(flexibility,2);
end