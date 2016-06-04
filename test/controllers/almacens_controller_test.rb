require 'test_helper'

class AlmacensControllerTest < ActionController::TestCase
  setup do
    @almacen = almacens(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:almacens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create almacen" do
    assert_difference('Almacen.count') do
      post :create, almacen: { _id: @almacen._id, despacho: @almacen.despacho, espacioTotal: @almacen.espacioTotal, espacioUtilizado: @almacen.espacioUtilizado, pulmon: @almacen.pulmon, recepcion: @almacen.recepcion }
    end

    assert_redirected_to almacen_path(assigns(:almacen))
  end

  test "should show almacen" do
    get :show, id: @almacen
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @almacen
    assert_response :success
  end

  test "should update almacen" do
    patch :update, id: @almacen, almacen: { _id: @almacen._id, despacho: @almacen.despacho, espacioTotal: @almacen.espacioTotal, espacioUtilizado: @almacen.espacioUtilizado, pulmon: @almacen.pulmon, recepcion: @almacen.recepcion }
    assert_redirected_to almacen_path(assigns(:almacen))
  end

  test "should destroy almacen" do
    assert_difference('Almacen.count', -1) do
      delete :destroy, id: @almacen
    end

    assert_redirected_to almacens_path
  end
end
