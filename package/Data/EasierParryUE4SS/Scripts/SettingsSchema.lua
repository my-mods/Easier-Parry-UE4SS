-- Settings contract shared by the loader and Mod Setting Menu. MIT License.
return {
    {key="enabled", default=1, values={0,1}},
    {key="factor", default=2, min=0.1, max=50, integer=false},
    {key="debugLogging", default=0, values={0,1}},
}
