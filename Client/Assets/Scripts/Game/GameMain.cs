using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using XLua.LuaDLL;

public class GameMain : MonoBehaviour
{
    public TextAsset GameMainLua;

    private XLua.LuaEnv luaEnv;

    private void Awake()
    {
        DontDestroyOnLoad(this);
    }

    // Start is called before the first frame update
    void Start()
    {
        luaEnv = new XLua.LuaEnv();
        luaEnv.AddLoader((ref string filepath) =>
        {
            string path = PathDefines.luaDataPath + filepath + ".lua";
            return File.ReadAllBytes(path);
        });
        luaEnv.DoString(GameMainLua.text, "GameMainLua");
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnDestroy()
    {
        if (luaEnv != null)
            luaEnv.Dispose();
        luaEnv = null;
    }
}
