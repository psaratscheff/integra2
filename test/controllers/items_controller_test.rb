require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @item = items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post :create, item: { Costo_Unitario: @item.Costo_Unitario, Descripcion: @item.Descripcion, Grupo: @item.Grupo, Lote: @item.Lote, Precio_Unitario: @item.Precio_Unitario, Sku1: @item.Sku1, Sku2: @item.Sku2, Sku3: @item.Sku3, Sku4: @item.Sku4, Sku: @item.Sku, Tiempo_Medio: @item.Tiempo_Medio, Tipo: @item.Tipo, Unidades: @item.Unidades }
    end

    assert_redirected_to item_path(assigns(:item))
  end

  test "should show item" do
    get :show, id: @item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item
    assert_response :success
  end

  test "should update item" do
    patch :update, id: @item, item: { Costo_Unitario: @item.Costo_Unitario, Descripcion: @item.Descripcion, Grupo: @item.Grupo, Lote: @item.Lote, Precio_Unitario: @item.Precio_Unitario, Sku1: @item.Sku1, Sku2: @item.Sku2, Sku3: @item.Sku3, Sku4: @item.Sku4, Sku: @item.Sku, Tiempo_Medio: @item.Tiempo_Medio, Tipo: @item.Tipo, Unidades: @item.Unidades }
    assert_redirected_to item_path(assigns(:item))
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item
    end

    assert_redirected_to items_path
  end
end
