function setHideoutData(teamElement, hideout)
    setElementData(teamElement, getHideoutDataKey(), hideout)
    setCachedHideout(teamElement, hideout)
end