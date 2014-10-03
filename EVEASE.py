## ***** BEGIN GPL LICENSE BLOCK *****
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
# ***** END GPL LICENCE BLOCK *****

#--- REQUIRED OPTIONS --------
#- Make Normals Consistent
#- Remove Doubles

bl_info = {
    "name": "EVE Scene Exporter",
    "author": "Egor Vilkin, EVil corp.",
    "version": ( 1, 0),
    "blender": ( 2, 7, 1 ),
    "api": 36079,
    "location": "File > Export > EVE Scene Export(.ase)",
    "description": "EVil Engine Scene Export(.ase)",
    "warning": "",
    "wiki_url": "",
    "tracker_url": "",
    "category": "Import-Export"
}

"""
--  This script is intended to export in the ASE file format for STATIC MESHES ONLY.
--  This script WILL NOT export skeletal meshes, these should be exported using a
--  different file format.
"""

import os
import bpy
import math
import time
import bmesh

# settings
aseFloat = lambda x: '''{0: 0.4f}'''.format( x )
optionScale = 1.0
optionSmoothingGroups = True

# ASE components
aseHeader = ''
aseScene = ''
aseMaterials = ''
aseGeometry = ''

# Other
matList = []
numMats = 0
currentMatId = 0

#=== Error ==================================================================
class Error( Exception ):

    def __init__( self, message ):
        self.message = message
        print( '\n\n' + message + '\n\n' )

#=== Header =================================================================
class cHeader:
    def __init__( self ):
        self.comment = "EVE Scene Exporter v1.0"

    def __repr__( self ):
        return '''*BLENDER_ASCIIEXPORT\n*COMMENT "{0}"\n'''.format( self.comment )

#=== Scene ==================================================================
class cScene:
    def __init__( self ):
        self.filename = bpy.data.filepath
        self.firstframe = bpy.context.scene.frame_start
        self.lastframe = bpy.context.scene.frame_end
        self.framespeed = bpy.context.scene.frame_step
        #self.ticksperframe = 160
        #self.backgroundstatic = ''.join( [aseFloat( x ) for x in [0.0, 0.0, 0.0]] )
        #self.ambientstatic = ''.join( [aseFloat( x ) for x in [0.0, 0.0, 0.0]] )

    def __repr__( self ):
        return '''*SCENE {{\n\t*SCENE_FILENAME "{0}"\n\t*SCENE_FIRSTFRAME {1}\n\t*SCENE_LASTFRAME {2}\n\t*SCENE_FRAMESPEED {3}\n}}\n'''.format( self.filename, self.firstframe, self.lastframe, self.framespeed )

#=== Materials ==============================================================
class cMaterials:
    def __init__( self ):
        global optionSubmaterials
        global matList
        global numMats

        self.material_list = []

        # Get all of the materials used by non-collision object meshes  
        for object in bpy.context.selected_objects:
            if collisionObject( object ) == True:
                continue
            elif object.type != 'MESH':
                continue
            else:
                print( object.name + ': Constructing Materials' )
                for slot in object.material_slots:
                    # if the material is not in the material_list, add it
                    if self.material_list.count( slot.material ) == 0:
                        self.material_list.append( slot.material )
                        matList.append( slot.material.name )

        self.material_count = len( self.material_list )
        numMats = self.material_count
        self.dump = cMultiMaterials( self.material_list )

    def __repr__( self ):
        return str( self.dump )

class cMultiMaterials:
    def __init__( self, material_list ):
        self.numMtls = len( material_list )
        # Initialize material information
        self.dump = '''*MATERIAL_LIST {{\n\t*MATERIAL_COUNT {0}'''.format( str( self.numMtls ) )

        for index, slot in enumerate( material_list ):
            self.dump += '''\n\t*MATERIAL {0} {{{1}\n\t}}'''.format( index, cMaterial( slot ) )

        self.dump += '\n}'

    def __repr__( self ):
        return self.dump

class cMaterial:
    def __init__( self, slot ):
        self.dump = ''
        self.name = slot.name
        self.matClass = 'Standard'
        self.ambient = ''.join( [aseFloat( x ) for x in [0.0, 0.0, 0.0]] )
        self.diffuse = ''.join( [aseFloat( x ) for x in slot.diffuse_color] )
        self.specular = ''.join( [aseFloat( x ) for x in slot.specular_color] )
        self.shine = aseFloat( slot.specular_hardness / 511 )
        self.shinestrength = aseFloat( slot.specular_intensity )
        self.transparency = aseFloat( slot.translucency * slot.alpha )
        self.wiresize = aseFloat( 1.0 )

        # Material Definition
        self.shading = str( slot.specular_shader ).capitalize()
        self.xpfalloff = aseFloat( 0.0 )
        self.xptype = 'Filter'
        self.falloff = 'In'
        self.soften = False
        self.diffusemap = cDiffusemap( slot.texture_slots[0] )
        self.submtls = []
        self.selfillum = aseFloat( slot.emit )
        self.dump = '''\n\t\t*MATERIAL_NAME "{0}"\n\t\t*MATERIAL_CLASS "{1}"\n\t\t*MATERIAL_AMBIENT {2}\n\t\t*MATERIAL_DIFFUSE {3}\n\t\t*MATERIAL_SPECULAR {4}\n\t\t*MATERIAL_SHINE {5}\n\t\t*MATERIAL_SHINESTRENGTH {6}\n\t\t*MATERIAL_TRANSPARENCY {7}\n\t\t*MATERIAL_WIRESIZE {8}\n\t\t*MATERIAL_SHADING {9}\n\t\t*MATERIAL_XP_FALLOFF {10}\n\t\t*MATERIAL_SELFILLUM {11}\n\t\t*MATERIAL_FALLOFF {12}\n\t\t*MATERIAL_XP_TYPE {13}{14}'''.format( self.name, self.matClass, self.ambient, self.diffuse, self.specular, self.shine, self.shinestrength, self.transparency, self.wiresize, self.shading, self.xpfalloff, self.selfillum, self.falloff, self.xptype, self.diffdump() )

    def diffdump( self ):
        for x in [self.diffusemap]:
            return x

    def __repr__( self ):
        return self.dump

class cDiffusemap:
    def __init__( self, slot ):
        import os
        self.dump = ''
        if slot is None:
            self.name = 'default'
            self.mapclass = 'Bitmap'
            self.bitmap = 'None'
        else:
            self.name = slot.name
            if slot.texture.type == 'IMAGE':
                self.mapclass = 'Bitmap'
                self.bitmap = slot.texture.image.filepath
            else:
                self.mapclass = 'Bitmap'
                self.bitmap = 'None'
        self.subno = 1
        self.amount = aseFloat( 1.0 )
        self.type = 'Screen'
        self.uoffset = aseFloat( 0.0 )
        self.voffset = aseFloat( 0.0 )
        self.utiling = aseFloat( 1.0 )
        self.vtiling = aseFloat( 1.0 )
        self.angle = aseFloat( 0.0 )
        self.blur = aseFloat( 1.0 )
        self.bluroffset = aseFloat( 0.0 )
        self.noiseamt = aseFloat( 1.0 )
        self.noisesize = aseFloat( 1.0 )
        self.noiselevel = 1
        self.noisephase = aseFloat( 0.0 )
        self.bitmapfilter = 'Pyramidal'

        self.dump = '''\n\t\t*MAP_DIFFUSE {{\n\t\t\t*MAP_NAME "{0}"\n\t\t\t*MAP_CLASS "{1}"\n\t\t\t*MAP_SUBNO {2}\n\t\t\t*MAP_AMOUNT {3}\n\t\t\t*BITMAP "{4}"\n\t\t\t*MAP_TYPE {5}\n\t\t\t*UVW_U_OFFSET {6}\n\t\t\t*UVW_V_OFFSET {7}\n\t\t\t*UVW_U_TILING {8}\n\t\t\t*UVW_V_TILING {9}\n\t\t\t*UVW_ANGLE {10}\n\t\t\t*UVW_BLUR {11}\n\t\t\t*UVW_BLUR_OFFSET {12}\n\t\t\t*UVW_NOUSE_AMT {13}\n\t\t\t*UVW_NOISE_SIZE {14}\n\t\t\t*UVW_NOISE_LEVEL {15}\n\t\t\t*UVW_NOISE_PHASE {16}\n\t\t\t*BITMAP_FILTER {17}\n\t\t}}'''.format( self.name, self.mapclass, self.subno, self.amount, self.bitmap, self.type, self.uoffset, self.voffset, self.utiling, self.vtiling, self.angle, self.blur, self.bluroffset, self.noiseamt, self.noisesize, self.noiselevel, self.noisephase, self.bitmapfilter )

    def __repr__( self ):
        return self.dump

#=== Geometry ===============================================================
class cGeomObject:
    def __init__(self, object):
        print(object.name + " : Parsing Geometry")
        global currentMatId

        self.name = object.name
        self.prop_motionblur = 0
        self.prop_castshadow = 1
        self.prop_recvshadow = 1

        self.nodetm = cNodeTM(object)
        self.mesh = cMesh(object)
        if self.mesh.mp.hasTexture:
            self.material_ref = currentMatId
            if currentMatId < numMats - 1:
                currentMatId += 1
            else:
                currentMatId = 0
            self.dump = '''\n*GEOMOBJECT {{\n\t*NODE_NAME "{0}"\n{1}\n{2}\n\t*PROP_MOTIONBLUR {3}\n\t*PROP_CASTSHADOW {4}\n\t*PROP_RECVSHADOW {5}\n\t*MATERIAL_REF {6}\n}}'''.format(self.name, self.nodetm, self.mesh, self.prop_motionblur, self.prop_castshadow, self.prop_recvshadow, self.material_ref)
        else:
            self.material_ref = -1
            self.dump = '''\n*GEOMOBJECT {{\n\t*NODE_NAME "{0}"\n{1}\n{2}\n\t*PROP_MOTIONBLUR {3}\n\t*PROP_CASTSHADOW {4}\n\t*PROP_RECVSHADOW {5}\n}}'''.format(self.name, self.nodetm, self.mesh, self.prop_motionblur, self.prop_castshadow, self.prop_recvshadow)

    def __repr__(self):
        return self.dump

class cNodeTM:
    def __init__( self, object ):
        self.name = object.name
        self.inherit_pos = '0 0 0'
        self.inherit_rot = '0 0 0'
        self.inherit_scl = '0 0 0'
        self.tm_row0 = '1.0000 0.0000 0.0000'
        self.tm_row1 = '0.0000 1.0000 0.0000'
        self.tm_row2 = '0.0000 0.0000 1.0000'
        self.tm_row3 = '0.0000 0.0000 0.0000'
        self.tm_pos = '0.0000 0.0000 0.0000'
        self.tm_rotaxis = '0.0000 0.0000 0.0000'
        self.tm_rotangle = '0.0000'
        self.tm_scale = '1.0000 1.0000 1.0000'
        self.tm_scaleaxis = '0.0000 0.0000 0.0000'
        self.tm_scaleaxisang = '0.0000'

        self.dump = '''\t*NODE_TM {{\n\t\t*NODE_NAME "{0}"\n\t\t*INHERIT_POS {1}\n\t\t*INHERIT_ROT {2}\n\t\t*INHERIT_SCL {3}\n\t\t*TM_ROW0 {4}\n\t\t*TM_ROW1 {5}\n\t\t*TM_ROW2 {6}\n\t\t*TM_ROW3 {7}\n\t\t*TM_POS {8}\n\t\t*TM_ROTAXIS {9}\n\t\t*TM_ROTANGLE {10}\n\t\t*TM_SCALE {11}\n\t\t*TM_SCALEAXIS {12}\n\t\t*TM_SCALEAXISANG {13}\n\t}}'''.format( self.name, self.inherit_pos, self.inherit_rot, self.inherit_scl, self.tm_row0, self.tm_row1, self.tm_row2, self.tm_row3, self.tm_pos, self.tm_rotaxis, self.tm_rotangle, self.tm_scale, self.tm_scaleaxis, self.tm_scaleaxisang )

    def __repr__( self ):
        return self.dump

class cMesh:
    def __init__(self, object):
        global currentMatId
        global numMats
        
        bpy.ops.mesh.reveal

        self.mp = MeshProcessor()
        if collisionObject(object) == False:
            self.mp.prepareVertexAndFaceLists(object)
            self.mp.setNormals(object)
    
    def __repr__(self):
        return self.mp.mesh_str()

#--- EVE Processor ---------------------------
class MeshProcessor:
    def __init__(self):
        self.vertexList = []
        self.faceList = []
        self.hasTexture = False
        self.hasColor = False
    
        self.timevalue = 0
        self.materialID = currentMatId;
    
    # duplicate vertices with several tex coords
    def prepareVertexAndFaceLists(self, object):
        mesh = object.data
        uv_map = [None]
        
        self.vertexList = [None] * len(object.data.vertices)
        self.hasTexture = not (mesh.uv_layers.active is None)
        self.hasColor = (len(mesh.vertex_colors) > 0)
        if self.hasTexture:
            uv_map = mesh.uv_layers.active.data;
        
        colorIndex = 0
        for face in mesh.polygons:
            vertIndices = []
            
            for li in range(face.loop_start, face.loop_start + face.loop_total):
                index = mesh.loops[li].vertex_index
                coord = object.data.vertices[index].co.to_tuple(4)
                uv = [0,0]
                if self.hasTexture:
                    uv = uv_map[li].uv
                color = [1,1,1]
                if self.hasColor:
                    color = mesh.vertex_colors[0].data[colorIndex].color
                    colorIndex += 1
                    print('*VERTEX ' + str(index))
                    print('*COLOR ' + str(color))
                
                v = VertexData(index, coord, uv, color)
                vi = self.vertexList[index]
                if vi is None:
                    # set vertex
                    self.vertexList[index] = v
                else:
                    # check if exactly same vertex existst
                    v_exists = False
                    for vj in self.vertexList:
                        if v == vj:
                            v_exists = True
                            v.index = vj.index
                            break
                    # add vertex with new TexCoords
                    if not v_exists:
                        print('Duplicate vertex #' + str(v.index))
                        v.index = len(self.vertexList)
                        self.vertexList.append(v)
                # add vertex to face's list
                vertIndices.append(v.index)
            f = FaceData(face.index, vertIndices)
            f.materialID = self.materialID
            self.faceList.append(f)
        
        print('Face count: ' + str(len(self.faceList)))
        print('Vertex count: ' + str(len(self.vertexList)))

    def setNormals(self, object):
        mesh = object.data
        for face in mesh.polygons:
            self.faceList[face.index].normal = face.normal.to_tuple(4)
            for i in range(len(face.vertices)):
                vi_private = self.faceList[face.index].vertices[i]
                vi_public = face.vertices[i]
                self.vertexList[vi_private].normal = mesh.vertices[vi_public].normal.to_tuple(4)

    def mesh_str(self):
        output = '''\t*MESH {{\n\t\t*TIMEVALUE {0}'''.format(str(self.timevalue))
        output += self.vertex_list_str()
        output += self.face_list_str()
        if self.hasTexture:
            output += self.vTexture_list_str()
        if self.hasColor:
            output += self.vColor_list_str()
        output += self.normal_list_str()
        output += '\n\t}'
        return output

    def vertex_list_str(self):
        output = '''\n\t\t*MESH_NUMVERTEX {0}'''.format(len(self.vertexList))
        output += '''\n\t\t*MESH_VERTEX_LIST {\n'''
        for v in self.vertexList:
            if isinstance(v, VertexData):
                output += v.vertex_str()
        output += '''\t\t}'''
        return output

    def vTexture_list_str(self):
        output = '''\n\t\t*MESH_NUMTVERTEX {0}'''.format(len(self.vertexList))
        output += '''\n\t\t*MESH_TVERTLIST {\n'''
        for v in self.vertexList:
            if isinstance(v, VertexData):
                output += v.tvert_str()
        output += '''\t\t}'''
        return output

    def vColor_list_str(self):
        output = '''\n\t\t*MESH_NUMCVERTEX {0}'''.format(len(self.vertexList))
        output += '''\n\t\t*MESH_CVERTLIST {\n'''
        for v in self.vertexList:
            if isinstance(v, VertexData):
                output += v.cvert_str()
        output += '''\t\t}'''
        return output

    def face_list_str(self):
        output = '''\n\t\t*MESH_NUMFACES {0}'''.format(len(self.faceList))
        output += '''\n\t\t*MESH_FACE_LIST {\n'''
        for f in self.faceList:
            if isinstance(f, FaceData):
                output += f.face_str()
        output += '''\t\t}'''
        return output

    def normal_list_str(self):
        output = '''\n\t\t*MESH_NORMALS {\n'''
        for v in self.vertexList:
            if isinstance(v, VertexData):
                output += v.vertex_normal_str()
        output += '\n'
        for f in self.faceList:
            if isinstance(f, FaceData):
                output += f.face_normal_str()
        output += '''\t\t}'''
        return output


class VertexData:
    def __init__(self, index, coord, texCoord, color):
        self.index = index
        
        self.x = coord[0]
        self.y = coord[1]
        self.z = coord[2]
        
        self.u = texCoord[0]
        self.v = texCoord[1]
        
        self.r = color[0]
        self.g = color[1]
        self.b = color[2]
    
        self.normal = [0,0,0]

    def __eq__(self, other):
        return isinstance(other, VertexData) and (self.x == other.x) and (self.y == other.y) and (self.z == other.z) and (self.r == other.r) and (self.g == other.g) and (self.b == other.b) and (self.u == other.u) and (self.v == other.v)
    def __ne__(self, other):
        return not(self == other)

    def vertex_str(self):
        return '''\t\t\t*MESH_VERTEX {0} {1} {2} {3}\n'''.format(self.index, aseFloat(self.x), aseFloat(self.y), aseFloat(self.z))
    def tvert_str(self):
        return '''\t\t\t*MESH_TVERT {0} {1} {2}\n'''.format(self.index, aseFloat(self.u), aseFloat(self.v))
    def cvert_str(self):
        return '''\t\t\t*MESH_CVERT {0} {1} {2} {3}\n'''.format(self.index, aseFloat(self.r), aseFloat(self.g), aseFloat(self.b))
    def cvert_str(self):
        return '''\t\t\t*MESH_VERTCOL {0} {1} {2} {3}\n'''.format(self.index, aseFloat(self.r), aseFloat(self.g), aseFloat(self.b))
    def vertex_normal_str(self):
        return '''\t\t\t*MESH_VERTEXNORMAL {0} {1} {2} {3}\n'''.format(self.index, aseFloat(self.normal[0]), aseFloat(self.normal[1]), aseFloat(self.normal[2]))

    def __repr__(self):
        return self.vertex_str() + self.tvert_str()

class FaceData:
    def __init__(self, index, vertexIndices):
        self.index = index
        self.vertices = vertexIndices    # array[3]
        self.materialID = 0
        self.smothID = 0
        self.normal = [0,0,0]

    def face_str(self):
        return '''\t\t\t*MESH_FACE {0}: A: {1} B: {2} C: {3} *MESH_SMOOTHING {4} *MESH_MTLID {5}\n'''.format(self.index, self.vertices[0], self.vertices[1], self.vertices[2], self.smothID, self.materialID)
    def face_normal_str(self):
        return '''\t\t\t*MESH_FACENORMAL {0} {1} {2} {3}\n'''.format(self.index, aseFloat(self.normal[0]), aseFloat(self.normal[1]), aseFloat(self.normal[2]))

    def __repr__(self):
        return self.face_str()

#== Smoothing Groups and Helper Methods =================================
def defineSmoothing( self, object ):
    print( object.name + ": Constructing Smoothing Groups" )

    seam_edge_list = []
    sharp_edge_list = []

    _mode = bpy.context.scene.objects.active.mode
    bpy.ops.object.mode_set( mode = 'EDIT' )
    bpy.ops.mesh.select_all( action = 'DESELECT' )
    setSelMode( 'EDGE' )

    # Get seams and clear them
    bpy.ops.object.mode_set( mode = 'OBJECT' )
    for edge in object.data.edges:
        if edge.use_seam:
            seam_edge_list.append( edge.index )
            edge.select = True

    bpy.ops.object.mode_set( mode = 'EDIT' )
    bpy.ops.mesh.select_all( action = 'SELECT' )
    bpy.ops.mesh.mark_seam( clear = True )

    # Get sharp edges, convert them to seams
    bpy.ops.mesh.select_all( action = 'DESELECT' )
    bpy.ops.object.mode_set( mode = 'OBJECT' )
    for edge in object.data.edges:
        if edge.use_edge_sharp:
            sharp_edge_list.append( edge )
            edge.select = True

    bpy.ops.object.mode_set( mode = 'EDIT' )
    bpy.ops.mesh.mark_seam()

    bpy.ops.mesh.select_all( action = 'DESELECT' )

    smoothing_groups = []
    face_list = []

    mode = getSelMode( self, False )
    setSelMode( 'FACE' )

    for face in object.data.polygons:
        face_list.append( face.index )

    while len( face_list ) > 0:
        bpy.ops.object.mode_set( mode = 'OBJECT' )
        object.data.polygons[face_list[0]].select = True
        bpy.ops.object.mode_set( mode = 'EDIT' )
        bpy.ops.mesh.select_linked( limit = True )

        # TODO - update when API is updated
        selected_faces = getSelectedFaces( self, True )
        smoothing_groups.append( selected_faces )
        for face_index in selected_faces:
            if face_list.count( face_index ) > 0:
                face_list.remove( face_index )
        bpy.ops.mesh.select_all( action = 'DESELECT' )

    setSelMode( mode, False )

    # Clear seams created by sharp edges
    bpy.ops.object.mode_set( mode = 'OBJECT' )
    for edge in object.data.edges:
        if edge.use_seam:
            edge.select = True

    bpy.ops.object.mode_set( mode = 'EDIT' )
    bpy.ops.mesh.mark_seam( clear = True )

    bpy.ops.mesh.select_all( action = 'DESELECT' )
    # Restore original uv seams
    bpy.ops.object.mode_set( mode = 'OBJECT' )
    for edge_index in seam_edge_list:
        object.data.edges[edge_index].select = True

    bpy.ops.object.mode_set( mode = 'EDIT' )
    bpy.ops.mesh.mark_seam()

    print( '\t' + str( len( smoothing_groups ) ) + ' smoothing groups found.' )
    return smoothing_groups

#===========================================================================
# // General Helpers
#===========================================================================

# Check if the mesh is a collider
# Return True if collision model, else: false
def collisionObject( object ):
    collisionPrefixes = ['UCX_', 'UBX_', 'USX_']
    for prefix in collisionPrefixes:
        if object.name.find( str( prefix ) ) >= 0:
            return True
    return False

# Set the selection mode    
def setSelMode( mode, default = True ):
    if default:
        if mode == 'VERT':
            bpy.context.tool_settings.mesh_select_mode = [True, False, False]
        elif mode == 'EDGE':
            bpy.context.tool_settings.mesh_select_mode = [False, True, False]
        elif mode == 'FACE':
            bpy.context.tool_settings.mesh_select_mode = [False, False, True]
        else:
            return False
    else:
        bpy.context.tool_settings.mesh_select_mode = mode
        return True
def getSelMode( self, default = True ):
    if default:
        if bpy.context.tool_settings.mesh_select_mode[0] == True:
            return 'VERT'
        elif bpy.context.tool_settings.mesh_select_mode[1] == True:
            return 'EDGE'
        elif bpy.context.tool_settings.mesh_select_mode[2] == True:
            return 'FACE'
        return False
    else:
        mode = []
        for value in bpy.context.tool_settings.mesh_select_mode:
            mode.append( value )

        return mode
def getSelectedFaces( self, index = False ):
    selected_faces = []
    # Update mesh data
    bpy.ops.object.editmode_toggle()
    bpy.ops.object.editmode_toggle()

    _mode = bpy.context.scene.objects.active.mode
    bpy.ops.object.mode_set( mode = 'EDIT' )

    object = bpy.context.scene.objects.active
    for face in object.data.polygons:
        if face.select == True:
            if index == False:
                selected_faces.append( face )
            else:
                selected_faces.append( face.index )

    bpy.ops.object.mode_set( mode = _mode )

    return selected_faces

#== Core ===================================================================
from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty, BoolProperty, FloatProperty

class ExportAse( bpy.types.Operator, ExportHelper ):
    '''Load an EVE Scene Export File'''
    bl_idname = "export.eve"
    bl_label = "Export"
    __doc__ = "EVE Scene Exporter (.ase)"
    filename_ext = ".ase"
    filter_glob = StringProperty( default = "*.ase", options = {'HIDDEN'} )

    filepath = StringProperty( 
        name = "File Path",
        description = "File path used for exporting the ASE file",
        maxlen = 1024,
        default = "export.ase")

    option_triangulate = BoolProperty(
            name = "Triangulate",
            description = "Triangulates all exportable objects",
            default = True)

    option_normals = BoolProperty( 
            name = "Recalculate Normals",
            description = "Recalculate normals before exporting",
            default = True)

    option_remove_doubles = BoolProperty( 
            name = "Remove Doubles",
            description = "Remove any duplicate vertices before exporting",
            default = True)

    option_apply_scale = BoolProperty( 
            name = "Scale",
            description = "Apply scale transformation",
            default = True )

    option_apply_location = BoolProperty( 
            name = "Location",
            description = "Apply location transformation",
            default = True )

    option_apply_rotation = BoolProperty( 
            name = "Rotation",
            description = "Apply rotation transformation",
            default = True )

    option_smoothinggroups = BoolProperty( 
            name = "Smoothing Groups",
            description = "Construct hard edge islands as smoothing groups",
            default = True )

    option_separate = BoolProperty( 
            name = "Separate",
            description = "A separate ASE file for every selected object",
            default = False)

    option_scale = FloatProperty( 
            name = "Scale",
            description = "Object scaling factor (default: 1.0)",
            min = 0.01,
            max = 1000.0,
            soft_min = 0.01,
            soft_max = 1000.0,
            default = 1.0 )

    def draw(self, context):
        layout = self.layout

        box = layout.box()
        box.label( 'Essentials:' )
        box.prop( self, 'option_triangulate' )
        box.prop( self, 'option_normals' )
        box.prop( self, 'option_remove_doubles' )
        box.label( "Transformations:" )
        box.prop( self, 'option_apply_scale' )
        box.prop( self, 'option_apply_rotation' )
        box.prop( self, 'option_apply_location' )
        box.label( "Advanced:" )
        box.prop( self, 'option_scale' )
        box.prop( self, 'option_smoothinggroups' )

    @classmethod
    def poll(cls, context):
        active = context.active_object
        selected = context.selected_objects
        camera = context.scene.camera
        ok = selected or camera
        return ok

    def writeASE(self, filename, data):
        print('\nWriting to', filename)
        try:
            file = open(filename, 'w')
        except IOError:
            print( 'Error: The file could not be written to. Aborting.' )
        else:
            file.write(data)
            file.close()

    def execute(self, context):
        start = time.clock()

        global optionScale
        global optionSmoothingGroups

        global aseHeader
        global aseScene
        global aseMaterials
        global aseGeometry

        global currentMatId
        global numMats
        global matList

        # Set globals and reinitialize ase components
        aseHeader = ''
        aseScene = ''
        aseMaterials = ''
        aseGeometry = ''

        optionScale = self.option_scale
        optionSmoothingGroups = self.option_smoothinggroups

        matList = []
        currentMatId = 0
        numMats = 0

        # Build ASE Header, Scene
        print('\nEVE Scene Export by EVil corp.\n' )
        print('Objects selected: ' + str( len( bpy.context.selected_objects ) ) )
        print('Scale: ' + str(optionScale))
        aseHeader = str( cHeader() )
        aseScene = str( cScene() )
        aseMaterials = str( cMaterials() )

        # Apply applicable options
        for object in bpy.context.selected_objects:
            if object.type == 'MESH':
                bpy.context.scene.objects.active = object
                object.select = True

                # Options
                bpy.ops.object.mode_set( mode = 'EDIT' )
                if self.option_remove_doubles:
                    bpy.ops.object.mode_set( mode = 'EDIT' )
                    bpy.ops.mesh.select_all( action = 'SELECT' )
                    bpy.ops.mesh.remove_doubles()
                if self.option_triangulate:
                    print( object.name + ': Converting to triangles' )
                    bpy.ops.mesh.select_all( action = 'SELECT' )
                    bpy.ops.mesh.quads_convert_to_tris()
                if self.option_normals:
                    print( object.name + ': Recalculating normals' )
                    bpy.ops.object.mode_set( mode = 'EDIT' )
                    bpy.ops.mesh.select_all( action = 'SELECT' )
                    bpy.ops.mesh.normals_make_consistent()

                # Transformations
                bpy.ops.object.mode_set( mode = 'OBJECT' )
                bpy.ops.object.transform_apply( location = self.option_apply_location, rotation = self.option_apply_rotation, scale = self.option_apply_scale )

                #Construct ASE Geometry Nodes
                aseGeometry += str( cGeomObject( object ) )
                bpy.ops.object.mode_set( mode = 'OBJECT' )

            else:
                continue

        aseModel = aseHeader + '\n'
        aseModel += aseScene
        aseModel += aseMaterials
        aseModel += aseGeometry

        # Write the ASE file
        self.writeASE( self.filepath, aseModel )
        # For debug
        #print(aseModel)

        lapse = ( time.clock() - start )
        print( 'Completed in ' + str( lapse ) + ' seconds' )

        return {'FINISHED'}

def menu_func( self, context ):
    self.layout.operator( ExportAse.bl_idname, text = "EVE Scene Exporter (.ase)" )

def register():
    bpy.utils.register_class( ExportAse )
    bpy.types.INFO_MT_file_export.append( menu_func )

def unregister():
    bpy.utils.unregister_class( ExportAse )
    bpy.types.INFO_MT_file_export.remove( menu_func )

if __name__ == "__main__":
    register()
    #run from command line
    bpy.ops.export.eve();
