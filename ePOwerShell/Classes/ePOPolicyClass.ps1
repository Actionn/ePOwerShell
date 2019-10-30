Class ePOPolicy {
    [System.String]     $FeatureID
    [System.String]    $FeatureName
    [System.Int32]     $ObjectID
    [System.String]     $ObjectName
    [System.String]    $ObjectNotes
    [System.String]    $ProductID
    [System.String]    $ProductName
    [System.Int32]     $TypeID
    [System.String]    $TypeName

    ePOPolicy([System.String] $FeatureID, [System.String] $FeatureName, [System.Int32] $ObjectID, [System.String] $ObjectName, [System.String] $ObjectNotes,
    [System.String] $ProductID, [System.String] $ProductName, [System.Int32] $TypeID, [System.String] $TypeName) {
        $this.FeatureID = $FeatureID
        $this.FeatureName = $FeatureName
        $this.ObjectID = $ObjectID
        $this.ObjectName = $ObjectName
        $this.ObjectNotes = $ObjectNotes
        $this.ProductID = $ProductID
        $this.ProductName = $ProductName
        $this.TypeID = $TypeID
        $this.TypeName = $TypeName
    }
}