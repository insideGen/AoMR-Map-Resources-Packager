#define Components_FindHandle 0
#define Components_FindResult 0
#dim Components_InnerMask[65536] ""
#define Components_InnerMaskReadIndex 0
#define Components_InnerMaskWriteIndex 0
#define Components_DestinationDir ""
#define Components_CurrentGroup ""
#define Components_FileFound 0

#sub Components_ProcessFoundFile
  #define InnerFileName FindGetFileName(Components_FindHandle)
  #if InnerFileName != "." && InnerFileName != ".."
    #if Components_InnerMaskReadIndex == 0
      #define RelativeFileName InnerFileName
    #else
      #define RelativeFileName Components_InnerMask[Components_InnerMaskReadIndex] + InnerFileName
    #endif
    #define AbsoluteFileName Components_InnerMask[0] + RelativeFileName
    #if DirExists(AbsoluteFileName)
      #expr Message("Directory " + Str(Components_InnerMaskWriteIndex) + " > " + RelativeFileName + "\")
      #expr Components_InnerMask[Components_InnerMaskWriteIndex] = RelativeFileName + "\"
      #expr Components_InnerMaskWriteIndex = Components_InnerMaskWriteIndex + 1
    #elif Len(InnerFileName) >= Len(SteamUserId + "_") && Pos(UpperCase(SteamUserId) + "_", UpperCase(InnerFileName)) == 1 && RPos(".bak", InnerFileName) == 0
      #expr Message("File " + Str(Components_InnerMaskWriteIndex) + " > " + RelativeFileName)
      #expr Components_InnerMask[Components_InnerMaskWriteIndex] = RelativeFileName
      #expr Components_InnerMaskWriteIndex = Components_InnerMaskWriteIndex + 1
      #expr Components_FileFound = 1
    #endif
  #endif
#endsub

#sub Components_ProcessInnerMaskPosition
  #define RelativePath Components_InnerMask[Components_InnerMaskReadIndex]
  #if Components_InnerMaskReadIndex == 0
    #define AbsolutePath RelativePath
  #else
    #define AbsolutePath Components_InnerMask[0] + RelativePath
  #endif
  #if DirExists(AbsolutePath)
    #expr Message("Path " + Str(Components_InnerMaskReadIndex) + " > " + RelativePath)
    #for { Components_FindHandle = Components_FindResult = FindFirst(AbsolutePath + "*", faAnyFile); Components_FindResult; Components_FindResult = FindNext(Components_FindHandle) } \
      Components_ProcessFoundFile
  #endif
#endsub

#sub Components_CollectFiles
  #expr Components_InnerMaskWriteIndex = 1
  #if Len(Components_InnerMask[0]) > 1
    #expr Message("CollectFiles > " + Components_InnerMask[0] + "**\" + SteamUserId + "_*")
    #for { Components_InnerMaskReadIndex = 0; Components_InnerMaskReadIndex < Components_InnerMaskWriteIndex; Components_InnerMaskReadIndex++ } \
      Components_ProcessInnerMaskPosition
  #endif
#endsub

#sub Components_CreateComponent
  #define RelativePath Components_InnerMask[Components_InnerMaskReadIndex]
  #define AbsolutePath Components_InnerMask[0] + RelativePath
  #if FileExists(AbsolutePath)
    #define FormatedPath StringChange(StringChange(StringChange(StringChange(RelativePath, " ", "_"), "~", "_"), "-", "_"), ".", "_")
    #define FileName ExtractFileName(FormatedPath)
    #define FileGroup StringChange(ExtractFileDir(FormatedPath), "\", "_")
    #if Components_CurrentGroup != FileGroup
      #expr Components_CurrentGroup = FileGroup
Name: "{#FileGroup}"; Description: "{#FileGroup}"; Types: full
    #endif
Name: "{#FileGroup}\{#FileName}"; Description: "{#RelativePath}"; Types: full custom
  #endif
#endsub

#sub Components_IterateComponents
  #for { Components_InnerMaskReadIndex = 1; Components_InnerMaskReadIndex < Components_InnerMaskWriteIndex; Components_InnerMaskReadIndex++ } \
    Components_CreateComponent
#endsub

#sub Components_CreateFile
  #define RelativePath Components_InnerMask[Components_InnerMaskReadIndex]
  #define AbsolutePath Components_InnerMask[0] + RelativePath
  #if FileExists(AbsolutePath)
    #define FormatedPath StringChange(StringChange(StringChange(StringChange(RelativePath, " ", "_"), "~", "_"), "-", "_"), ".", "_")
    #define FileName ExtractFileName(FormatedPath)
    #define FileGroup StringChange(ExtractFileDir(FormatedPath), "\", "_")
Source: "{#AbsolutePath}"; DestDir: "{#Components_DestinationDir}{#ExtractFileDir(RelativePath)}"; Components: "{#FileGroup}\{#FileName}"; Flags: ignoreversion
  #endif
#endsub

#sub Components_IterateFiles
  #for { Components_InnerMaskReadIndex = 1; Components_InnerMaskReadIndex < Components_InnerMaskWriteIndex; Components_InnerMaskReadIndex++ } \
    Components_CreateFile
#endsub

#define Components_ListComponents(str SourcePath) \
  Components_InnerMask[0] = AddBackslash(SourcePath), \
  Components_CollectFiles, \
  Components_IterateComponents

#define Components_ListFiles(str SourcePath, str DestPath) \
  Components_InnerMask[0] = AddBackslash(SourcePath), \
  Components_DestinationDir = AddBackslash(DestPath), \
  Components_CollectFiles, \
  Components_IterateFiles

