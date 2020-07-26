
using UnityEngine;

public static class PathDefines
{
    public static string assetPath = Application.dataPath;
    public static string projectPath = Application.dataPath.Replace("Assets", "");
    public static string luaDataPath = Application.dataPath.Replace("Client/Assets", "") + "Data/";
}
